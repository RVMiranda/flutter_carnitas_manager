import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/database_provider.dart';
import '../../data/sync/critical_operation_repository.dart';
import '../../data/sync/sync_worker.dart';
import '../../core/utils/currency_utils.dart';
import '../../app/theme/exquisssita_tokens.dart';
import 'exquisssita_components.dart';

class CriticalOperationsSheet extends ConsumerWidget {
  const CriticalOperationsSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(criticalOperationsProvider);
    final operations = state.valueOrNull ?? [];
    final visible = operations
        .where(
          (o) => !o.acknowledged && o.state != CriticalOperationState.confirmed,
        )
        .toList();
    return SafeArea(
      child: SizedBox(
        height:
            MediaQuery.sizeOf(context).height *
            context.exq.metrics.sheetFraction,
        child: Column(
          children: [
            const ExquisssitaPageHeader(title: 'Pagos e inventario pendientes'),
            Expanded(
              child: state.isLoading
                  ? const ExquisssitaSkeleton()
                  : state.hasError
                  ? ExquisssitaErrorState(
                      onRetry: () => ref.invalidate(criticalOperationsProvider),
                    )
                  : visible.isEmpty
                  ? const SingleChildScrollView(
                      child: ExquisssitaEmptyState(
                        message: 'Sin operaciones por atender.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final operation = visible[index];
                        final payment = operation.kind == 'registrar_pago';
                        final label = switch (operation.state) {
                          CriticalOperationState.pendingSync =>
                            'Pendiente de confirmación',
                          CriticalOperationState.confirmed => 'Confirmada',
                          CriticalOperationState.rejected =>
                            'Rechazada por el servidor',
                          CriticalOperationState.requiresReview =>
                            'Resultado incierto: requiere revisión',
                        };
                        return Padding(
                          padding: EdgeInsets.all(context.exq.metrics.spaceL),
                          child: ExquisssitaSurface(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  payment
                                      ? 'Pago ${CurrencyUtils.format(operation.amountCents ?? 0)}'
                                      : 'Inventario: ${operation.quantity ?? 0} unidades',
                                ),
                                Text(
                                  '$label · Folio ${operation.id.substring(0, operation.id.length.clamp(0, 8))}',
                                ),
                                operation.state ==
                                        CriticalOperationState.pendingSync
                                    ? const SizedBox.shrink()
                                    : ExquisssitaAction(
                                        primary: false,
                                        label: operation.rejectionKnown
                                            ? 'Atender'
                                            : 'Consultar',
                                        onPressed: () async {
                                          final known =
                                              operation.rejectionKnown;
                                          final approved = await showExquisssitaModal<bool>(
                                            context: context,
                                            builder: (context) => ExquisssitaModal(
                                              title: known
                                                  ? 'Atender rechazo'
                                                  : 'Consultar resultado',
                                              actions: [
                                                ExquisssitaAction(
                                                  primary: false,
                                                  label: 'Volver',
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                ),
                                                ExquisssitaAction(
                                                  primary: false,
                                                  label: known
                                                      ? 'Atención realizada'
                                                      : 'Consultar',
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                ),
                                              ],
                                              child: Text(
                                                known
                                                    ? (payment
                                                          ? 'Este pago no fue aceptado. Si recibiste dinero, devuelve el importe o registra la incidencia antes de confirmar la atención. Esta acción deja constancia local; no realiza un reembolso bancario.'
                                                          : 'El movimiento no fue aceptado. La reserva local se liberó; verifica la mercancía y registra una nueva corrección si corresponde. El movimiento original se conserva.')
                                                    : 'Se reenviará la misma operación con el mismo identificador. No registres un pago o movimiento nuevo para resolver este caso.',
                                              ),
                                            ),
                                          );
                                          if (approved != true) return;
                                          try {
                                            final repository =
                                                CriticalOperationRepository(
                                                  ref.read(appDatabaseProvider),
                                                );
                                            if (known) {
                                              await repository
                                                  .acknowledgeRejection(
                                                    operation.id,
                                                  );
                                            } else {
                                              await repository.retryUnknown(
                                                operation.id,
                                              );
                                              await ref
                                                  .read(syncWorkerProvider)
                                                  .syncNow();
                                            }
                                          } catch (_) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'No fue posible actualizar la revisión.',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
