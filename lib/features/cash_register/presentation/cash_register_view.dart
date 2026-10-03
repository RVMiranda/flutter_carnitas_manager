import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../app/theme/exquisssita_tokens.dart';
import '../../../shared/widgets/exquisssita_components.dart';
import '../data/cash_register_providers.dart';
import 'cash_register_view_model.dart';

class CashRegisterView extends ConsumerStatefulWidget {
  const CashRegisterView({super.key});

  @override
  ConsumerState<CashRegisterView> createState() => _CashRegisterViewState();
}

class _CashRegisterViewState extends ConsumerState<CashRegisterView> {
  @override
  Widget build(BuildContext context) {
    final date = DateUtils.dateOnly(DateTime.now());
    final state = ref.watch(cashRegisterSummaryProvider(date));
    final closeState = ref.watch(cashRegisterViewModelProvider(date));
    final closeVm = ref.read(cashRegisterViewModelProvider(date).notifier);
    final header = ExquisssitaPageHeader(
      title: 'Corte de caja',
      action: ExquisssitaAction(
        primary: false,
        label: 'Volver',
        icon: Icons.arrow_back_outlined,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
    return Scaffold(
      body: state.when(
        loading: () =>
            ListView(children: [header, const ExquisssitaSkeleton()]),
        error: (_, _) =>
            ListView(children: [header, const ExquisssitaErrorState()]),
        data: (summary) => ListView(
          padding: EdgeInsets.all(context.exq.metrics.spaceXl),
          children: [
            header,
            Text(
              'Resumen del ${summary.date.day}/${summary.date.month}/${summary.date.year}',
              style: context.exq.label,
            ),
            SizedBox(height: context.exq.metrics.spaceXl),
            _AmountTile(label: 'Efectivo', cents: summary.cashCents),
            _AmountTile(label: 'Tarjeta', cents: summary.cardCents),
            _AmountTile(label: 'Otros métodos', cents: summary.otherCents),
            const Divider(),
            _AmountTile(
              label: 'Total',
              cents: summary.totalCents,
              emphasized: true,
            ),
            Text('Órdenes: ${summary.orderCount}', style: context.exq.body),
            ExquisssitaStatusBadge(
              label: summary.closed ? 'Cerrado' : 'Abierto',
            ),
            SizedBox(height: context.exq.metrics.spaceL),
            ExquisssitaAction(
              busy: closeState.closing,
              label: summary.closed ? 'Corte realizado' : 'Realizar corte',
              onPressed: summary.closed || closeState.closing
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(title: const Text('Confirmar corte'), content: const Text('El corte es append-only y no podrá editarse.'), actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Confirmar'))]));
                      if (confirmed == true) await closeVm.close(date);
                    },
              icon: Icons.lock_outline,
            ),
            if (closeState.failure != null) ExquisssitaErrorState(message: closeState.failure!.message),
            if (closeState.saved) const Text('Corte guardado localmente y pendiente de sincronizar.'),
            SizedBox(height: context.exq.metrics.spaceXxl),
            Text('Cortes anteriores', style: context.exq.label),
            SizedBox(height: context.exq.metrics.spaceS),
            Consumer(
              builder: (context, ref, _) => ref
                  .watch(cashRegisterClosuresProvider)
                  .when(
                    loading: () => const ExquisssitaSkeleton(),
                    error: (_, _) =>
                        const Text('No fue posible cargar el historial.'),
                    data: (closures) => closures.isEmpty
                        ? const Text('Aún no hay cortes registrados.')
                        : Column(
                            children: closures.take(10).map((closure) {
                              final date = DateFormat(
                                'dd/MM/yyyy',
                              ).format(closure.date);
                              return _AmountTile(
                                label: '$date · ${closure.orderCount} órdenes',
                                cents: closure.totalCents,
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
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.exq.metrics.spaceM),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: context.exq.metrics.spaceL,
      runSpacing: context.exq.metrics.spaceS,
      children: [
        Text(label, style: context.exq.label),
        Text(
          CurrencyUtils.format(cents),
          style: emphasized ? context.exq.currency : context.exq.currencySmall,
        ),
      ],
    ),
  );
}
