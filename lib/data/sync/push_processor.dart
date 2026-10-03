import '../repositories/sync_repository.dart';
import 'drift_sync_store.dart';
import 'retry_policy.dart';
import 'sync_models.dart';

class PushProcessor {
  PushProcessor(
    this.store,
    this.remote, {
    RetryPolicy? retry,
    this.classifier = const SyncErrorClassifier(),
  }) : retry = retry ?? RetryPolicy();
  final DriftSyncStore store;
  final SyncRepository remote;
  final RetryPolicy retry;
  final SyncErrorClassifier classifier;
  Future<bool> run({required bool Function() canRun}) async {
    var succeeded = true;
    for (final operation in await store.due(
      DateTime.now().millisecondsSinceEpoch,
    )) {
      if (!canRun()) break;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (!await store.claim(operation.id, now)) continue;
      try {
        final result = await remote.push(
          operation,
          await store.baseVersion(operation.id),
        );
        if (result['status'] == 'rejected') {
          await store.finish(
            operation,
            status: 'failed',
            now: now,
            code: 'server_rejected',
            rejectionKnown: true,
            receipt: result,
          );
          succeeded = false;
          continue;
        }
        final critical =
            operation.entity == 'registrar_pago' ||
            operation.entity == 'registrar_movimiento_inventario';
        if ((critical && result['status'] != 'confirmed') ||
            (operation.entity == 'registrar_pago' &&
                result['transaction_id'] is! String) ||
            (operation.entity == 'registrar_movimiento_inventario' &&
                result['movement_id'] is! String)) {
          throw const SyncContractException();
        }
        await store.finish(
          operation,
          status: 'completed',
          now: now,
          version: result['version'] as int?,
          receipt: result,
        );
      } catch (error) {
        succeeded = false;
        final kind = classifier.classify(error);
        final temporary =
            kind == SyncErrorKind.transient ||
            kind == SyncErrorKind.authentication;
        final willRetry =
            temporary && operation.attempts + 1 < retry.maxAttempts;
        await store.finish(
          operation,
          status: willRetry ? 'pending' : 'failed',
          now: now,
          code: classifier.safeCode(kind),
          nextAttempt: willRetry
              ? now + retry.delay(operation.attempts + 1).inMilliseconds
              : null,
        );
        if (temporary) break;
      }
    }
    return succeeded;
  }
}
