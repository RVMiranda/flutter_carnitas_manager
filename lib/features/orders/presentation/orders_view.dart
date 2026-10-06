import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/exquisssita_components.dart';
import '../../../app/theme/exquisssita_tokens.dart';
import '../../../core/utils/currency_utils.dart';
import '../data/orders_providers.dart';
import '../domain/order_models.dart';
import 'orders_view_model.dart';

class OrdersView extends ConsumerWidget {
  const OrdersView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(ordersViewModelProvider);
    final m = context.exq.metrics;
    return SafeArea(
      child: Column(
        children: [
          ExquisssitaPageHeader(
            title: 'Mesas y pedidos',
            subtitle: 'Toca una mesa para abrir o continuar su orden.',
            action: ExquisssitaAction(
              key: const Key('add_table_button'),
              label: 'Agregar mesa',
              icon: Icons.add,
              onPressed: action.isLoading
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      builder: (_) => const _AddTableDialog(),
                    ),
            ),
          ),
          if (action.hasError)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.spaceXl),
              child: Text(
                ref.read(ordersViewModelProvider.notifier).errorMessage,
                style: context.exq.body,
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final largeText =
                    MediaQuery.textScalerOf(context).scale(16) > 24;
                final columns = largeText
                    ? 1
                    : constraints.maxWidth < 600
                    ? 2
                    : constraints.maxWidth < 1000
                    ? 3
                    : 4;
                return ref
                    .watch(tablesProvider)
                    .when(
                      loading: () => const ExquisssitaSkeleton(),
                      error: (_, _) => ExquisssitaErrorState(
                        message: 'No se pudieron cargar las mesas.',
                        onRetry: () => ref.invalidate(tablesProvider),
                      ),
                      data: (tables) => CustomScrollView(
                        slivers: [
                          if (tables.isEmpty)
                            const SliverToBoxAdapter(
                              child: ExquisssitaEmptyState(
                                message:
                                    'Aún no hay mesas. Agrega la primera para comenzar.',
                                icon: Icons.table_restaurant_outlined,
                              ),
                            ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              m.spaceXl,
                              m.spaceS,
                              m.spaceXl,
                              m.spaceXxl,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: m.spaceL,
                                    mainAxisSpacing: m.spaceL,
                        childAspectRatio: m.tableCardAspectRatio,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => index == tables.length
                                    ? _TakeawayCard(
                                        onTap: action.isLoading
                                            ? null
                                            : () => _open(
                                                context,
                                                ref,
                                                null,
                                                ServiceType.takeaway,
                                              ),
                                      )
                                    : _TableCard(
                                        table: tables[index],
                                        onTap: action.isLoading
                                            ? null
                                            : () => _open(
                                                context,
                                                ref,
                                                tables[index].id,
                                                ServiceType.table,
                                              ),
                                      ),
                                childCount: tables.length + 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

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
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => OrderDetailView(orderId: order.id)),
      );
    }
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.onTap});
  final TableSummary table;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ExquisssitaPressable(
    key: ValueKey('table-${table.id}'),
    label:
        'Mesa ${table.number}, ${table.status}. ${table.available ? 'Abrir orden' : 'Continuar orden'}',
    onPressed: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: table.available ? context.exq.card : context.exq.secondary,
        borderRadius: BorderRadius.circular(context.exq.metrics.radiusCard),
        border: Border.all(color: context.exq.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.exq.metrics.spaceM),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mesa ${table.number}',
                style: context.exq.heading,
                textAlign: TextAlign.center,
              ),
              Text(table.status, style: context.exq.caption),
              if (table.syncFailed || table.pendingSync)
                Padding(
                  padding: EdgeInsets.only(top: context.exq.metrics.spaceS),
                  child: Text(
                    table.syncFailed
                        ? 'Revisar sincronización'
                        : 'Pendiente de envío',
                    style: context.exq.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TakeawayCard extends StatelessWidget {
  const _TakeawayCard({required this.onTap});
  final VoidCallback? onTap;
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
        child: Text(
          'Para llevar',
          style: context.exq.heading,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class _AddTableDialog extends ConsumerStatefulWidget {
  const _AddTableDialog();
  @override
  ConsumerState<_AddTableDialog> createState() => _AddTableDialogState();
}

class _AddTableDialogState extends ConsumerState<_AddTableDialog> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final saved = await ref
        .read(ordersViewModelProvider.notifier)
        .createTable(_number.text);
    if (mounted && saved) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);
    return ExquisssitaModal(
      title: 'Agregar mesa',
      actions: [
        ExquisssitaAction(
          label: 'Cancelar',
          primary: false,
          onPressed: state.isLoading ? null : () => Navigator.pop(context),
        ),
        ExquisssitaAction(
          key: const Key('save_table_button'),
          label: 'Guardar mesa',
          busy: state.isLoading,
          onPressed: _save,
        ),
      ],
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Se guardará en este dispositivo y se enviará cuando haya conexión.',
              style: context.exq.body,
            ),
            SizedBox(height: context.exq.metrics.spaceL),
            ExquisssitaFormField(
              key: const Key('table_number_field'),
              label: 'Número de mesa',
              controller: _number,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              enabled: !state.isLoading,
              onFieldSubmitted: (_) => state.isLoading ? null : _save(),
              validator: (value) {
                final n = int.tryParse(value?.trim() ?? '');
                return n == null || n < 1 || n > 9999
                    ? 'Ingresa un número entre 1 y 9999.'
                    : null;
              },
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(top: context.exq.metrics.spaceM),
                child: Text(
                  ref.read(ordersViewModelProvider.notifier).errorMessage,
                  style: context.exq.body,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailView extends ConsumerWidget {
  const OrderDetailView({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = context.exq.metrics;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(m.spaceM),
                child: ExquisssitaAction(
                  key: const Key('back_to_tables_button'),
                  label: 'Volver a mesas',
                  icon: Icons.arrow_back,
                  primary: false,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: ref
                  .watch(orderProvider(orderId))
                  .when(
                    loading: () => const ExquisssitaSkeleton(),
                    error: (_, _) => ExquisssitaErrorState(
                      message: 'No se pudo cargar la orden.',
                      onRetry: () => ref.invalidate(orderProvider(orderId)),
                    ),
                    data: (order) => order == null
                        ? const ExquisssitaEmptyState(
                            message: 'Orden no encontrada.',
                          )
                        : ListView(
                            padding: EdgeInsets.all(m.spaceXl),
                            children: [
                              Text(
                                order.tableNumber == null
                                    ? 'Orden para llevar'
                                    : 'Mesa ${order.tableNumber}',
                                style: context.exq.heading,
                              ),
                              SizedBox(height: m.spaceM),
                              ExquisssitaStatusBadge(
                                label: order.status == OrderStatus.open
                                    ? 'Orden abierta'
                                    : order.status == OrderStatus.cancelled
                                    ? 'Orden cancelada'
                                    : 'Orden cerrada',
                              ),
                              SizedBox(height: m.spaceXl),
                              if (order.pendingSync || order.syncFailed)
                                ExquisssitaStatusBadge(
                                  label: order.syncFailed
                                      ? 'Sincronización requiere revisión'
                                      : 'Pendiente de envío',
                                ),
                              if (order.syncFailed)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: m.spaceM,
                                  ),
                                  child: ExquisssitaAction(
                                    label: 'Reintentar envío anterior',
                                    primary: false,
                                    onPressed: () async {
                                      String message;
                                      try {
                                        message = await ref
                                            .read(
                                              ordersViewModelProvider.notifier,
                                            )
                                            .retryLegacy(orderId);
                                      } catch (_) {
                                        message =
                                            'No se pudo reintentar. Intenta nuevamente.';
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(message)),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              if (order.lines.isEmpty)
                                const ExquisssitaEmptyState(
                                  message: 'Agrega productos desde el menú.',
                                  icon: Icons.restaurant_menu,
                                ),
                              ...order.lines.map(
                                (line) => Padding(
                                  padding: EdgeInsets.only(bottom: m.spaceM),
                                  child: ExquisssitaSurface(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          line.name,
                                          style: context.exq.heading,
                                        ),
                                        Text(
                                          'Cantidad: ${line.quantity}',
                                          style: context.exq.body,
                                        ),
                                        Text(
                                          CurrencyUtils.format(
                                            line.subtotalCents,
                                          ),
                                          style: context.exq.label,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'Total: ${CurrencyUtils.format(order.totalCents)}',
                                style: context.exq.heading,
                              ),
                            ],
                          ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
