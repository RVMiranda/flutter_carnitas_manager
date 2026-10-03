import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/exquisssita_components.dart';
import '../../../app/theme/exquisssita_tokens.dart';
import '../data/orders_providers.dart';
import '../domain/order_models.dart';
import 'orders_view_model.dart';

class OrdersView extends ConsumerWidget {
  const OrdersView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 600
            ? 2
            : constraints.maxWidth < 1000
            ? 3
            : 4;
        return ref.watch(tablesProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Text('No se pudieron cargar las mesas.'),
          ),
          data: (tables) => tables.isEmpty
              ? const Center(child: Text('No hay mesas configuradas.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: tables.length + 1,
                  itemBuilder: (context, index) => index == tables.length
                      ? _TakeawayCard(
                          onTap: () => _open(
                            context,
                            ref,
                            null,
                            ServiceType.takeaway,
                          ),
                        )
                      : _TableCard(
                          table: tables[index],
                          onTap: () => _open(
                            context,
                            ref,
                            tables[index].id,
                            ServiceType.table,
                          ),
                        ),
                ),
        );
      },
    ),
  );

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    String? tableId,
    ServiceType type,
  ) async {
    final order = await ref
        .read(ordersViewModelProvider.notifier)
        .open(tableId: tableId, type: type);
    if (context.mounted && order != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailView(orderId: order.id)),
      );
    }
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.onTap});
  final TableSummary table;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ExquisssitaPressable(
    label: 'Mesa ${table.number}',
    onPressed: table.available ? onTap : null,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.exq.card,
        borderRadius: BorderRadius.circular(context.exq.metrics.radiusCard),
        border: Border.all(color: context.exq.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mesa ${table.number}', style: context.exq.heading),
            Text(table.status, style: context.exq.caption),
          ],
        ),
      ),
    ),
  );
}

class _TakeawayCard extends StatelessWidget {
  const _TakeawayCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ExquisssitaPressable(
    label: 'Pedido para llevar',
    onPressed: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.exq.secondary,
        borderRadius: BorderRadius.circular(context.exq.metrics.radiusCard),
      ),
      child: Center(
        child: Text('Para llevar', style: context.exq.heading),
      ),
    ),
  );
}

class OrderDetailView extends ConsumerWidget {
  const OrderDetailView({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: ref.watch(orderProvider(orderId)).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('No se pudo cargar la orden.')),
        data: (order) => order == null
            ? const Center(child: Text('Orden no encontrada.'))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Orden ${order.tableNumber ?? 'para llevar'}', style: context.exq.heading),
                  if (order.lines.isEmpty) const Text('Agrega productos desde el menú.'),
                  ...order.lines.map((line) => ListTile(
                    title: Text(line.name),
                    subtitle: Text('Cantidad: ${line.quantity}'),
                    trailing: Text('\$${(line.subtotalCents / 100).toStringAsFixed(2)}'),
                  )),
                  Text('Total: \$${(order.totalCents / 100).toStringAsFixed(2)}'),
                ],
              ),
      ),
    ),
  );
}
