import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/cash_register_providers.dart';

class CashRegisterView extends ConsumerWidget {
  const CashRegisterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.now();
    final state = ref.watch(cashRegisterSummaryProvider(date));
    return Scaffold(
      appBar: AppBar(title: const Text('Corte de caja')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('No se pudo cargar el resumen: $error')),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Resumen del ${summary.date.day}/${summary.date.month}/${summary.date.year}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _AmountTile(label: 'Efectivo', cents: summary.cashCents),
            _AmountTile(label: 'Tarjeta', cents: summary.cardCents),
            _AmountTile(label: 'Otros métodos', cents: summary.otherCents),
            const Divider(),
            _AmountTile(
              label: 'Total',
              cents: summary.totalCents,
              emphasized: true,
            ),
            ListTile(
              title: const Text('Órdenes'),
              trailing: Text('${summary.orderCount}'),
            ),
            ListTile(
              title: const Text('Estado'),
              trailing: Text(summary.closed ? 'Cerrado' : 'Abierto'),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: summary.closed
                  ? null
                  : () async {
                      try {
                        final result = await ref
                            .read(cashRegisterRepositoryProvider)
                            .close(date);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result.closed
                                    ? 'Corte guardado localmente y pendiente de sincronizar.'
                                    : 'Corte ya existente.',
                              ),
                            ),
                          );
                        }
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No se pudo cerrar la caja: $error',
                              ),
                            ),
                          );
                        }
                      }
                    },
              icon: const Icon(Icons.lock_outline),
              label: Text(
                summary.closed ? 'Corte realizado' : 'Realizar corte',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cortes anteriores',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) => ref
                  .watch(cashRegisterClosuresProvider)
                  .when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const Text(
                      'No fue posible cargar el historial.',
                    ),
                    data: (closures) => closures.isEmpty
                        ? const Text('Aún no hay cortes registrados.')
                        : Column(
                            children: closures.take(10).map((closure) {
                              final date = DateFormat(
                                'dd/MM/yyyy',
                              ).format(closure.date);
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.receipt_long_outlined,
                                ),
                                title: Text(date),
                                subtitle: Text(
                                  '${closure.orderCount} órdenes',
                                ),
                                trailing: Text(
                                  '\$${(closure.totalCents / 100).toStringAsFixed(2)}',
                                ),
                              );
                            }).toList(),
                          ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.cents,
    this.emphasized = false,
  });
  final String label;
  final int cents;
  final bool emphasized;
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(
      label,
      style: emphasized ? const TextStyle(fontWeight: FontWeight.bold) : null,
    ),
    trailing: Text(
      '\$${(cents / 100).toStringAsFixed(2)}',
      style: emphasized ? Theme.of(context).textTheme.titleLarge : null,
    ),
  );
}
