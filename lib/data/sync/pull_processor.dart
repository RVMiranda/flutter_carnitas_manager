import '../repositories/sync_repository.dart';
import 'drift_sync_store.dart';
import 'sync_models.dart';

class PullProcessor {
  PullProcessor(this.store, this.remote);
  final DriftSyncStore store;
  final SyncRepository remote;
  Future<void> run({
    required String scope,
    required bool Function() canRun,
  }) async {
    var cursor = await store.cursor(scope);
    int? watermark;
    while (canRun()) {
      final page = await remote.pull(cursor: cursor, watermark: watermark);
      if (remote.scope != scope || !canRun()) return;
      if (page.cursor < cursor ||
          page.cursor > page.watermark ||
          (watermark != null && page.watermark != watermark) ||
          (page.hasMore && page.cursor == cursor) ||
          page.changes.any(
            (c) => c.cursor <= cursor || c.cursor > page.cursor,
          )) {
        throw const SyncContractException();
      }
      await store.applyPage(scope, page);
      watermark = page.watermark;
      cursor = page.cursor;
      if (!page.hasMore) break;
    }
  }
}
