import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/exquisssita_tokens.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/permissions/permission.dart';
import '../../../data/local/database/app_database.dart';
import '../../../shared/widgets/exquisssita_components.dart';
import '../domain/payroll_models.dart';
import 'employee_view_model.dart';

class EmployeePaymentHistoryView extends ConsumerStatefulWidget {
  const EmployeePaymentHistoryView({
    super.key,
    required this.role,
    required this.employeeId,
  });

  final AppRole role;
  final String employeeId;

  @override
  ConsumerState<EmployeePaymentHistoryView> createState() =>
      _EmployeePaymentHistoryViewState();
}

class _EmployeePaymentHistoryViewState
    extends ConsumerState<EmployeePaymentHistoryView> {
  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeViewModelProvider(widget.role));
    final employee = state.employees
        .where((item) => item.id == widget.employeeId)
        .firstOrNull;
    final t = context.exq;
    final m = t.metrics;
    final payments = state.payments
        .where((payment) => payment.empleadoId == widget.employeeId)
        .toList();
    final byPeriod = <String, HistorialPagosEmpleadosTableData>{
      for (final payment in payments)
        if (payment.periodoInicio != null) payment.periodoInicio!: payment,
    };
    final legacy = payments.where((payment) {
      final paid = DateTime.tryParse(payment.fechaPago);
      return payment.periodoInicio == null &&
          paid != null &&
          paid.year == month.year &&
          paid.month == month.month;
    }).toList();
    final weeks = _weeksInMonth(month);
    final currentWeek = PayrollWeek.startOf(DateTime.now());
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final paidCount = weeks
        .where((week) => byPeriod.containsKey(PayrollWeek.dateKey(week)))
        .length;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(m.spaceXl),
                  child: Row(
                    children: [
                      ExquisssitaIconAction(
                        key: const ValueKey('payment-history-back'),
                        label: 'Volver a empleados',
                        icon: Icons.arrow_back_outlined,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: m.spaceM),
                      Expanded(
                        child: Text('Historial de pagos', style: t.heading),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.loading
                      ? const ExquisssitaSkeleton()
                      : employee == null
                      ? const ExquisssitaErrorState(
                          message: 'No se encontró al empleado.',
                        )
                      : ListView(
                          padding: EdgeInsets.fromLTRB(
                            m.spaceXl,
                            m.spaceS,
                            m.spaceXl,
                            m.spaceXxl,
                          ),
                          children: [
                            Text(
                              '${employee.nombre} ${employee.apellido}',
                              style: t.text.titleLarge,
                            ),
                            SizedBox(height: m.spaceS),
                            Text(
                              'Día habitual de pago: ${_weekdayName(employee.diaPago)}',
                              style: t.body,
                            ),
                            SizedBox(height: m.spaceL),
                            Row(
                              children: [
                                ExquisssitaIconAction(
                                  key: const ValueKey('previous-payroll-month'),
                                  label: 'Mes anterior',
                                  icon: Icons.chevron_left,
                                  onPressed: () => setState(
                                    () => month = DateTime(
                                      month.year,
                                      month.month - 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    PayrollWeek.monthLabel(month),
                                    textAlign: TextAlign.center,
                                    style: t.text.titleLarge,
                                  ),
                                ),
                                ExquisssitaIconAction(
                                  key: const ValueKey('next-payroll-month'),
                                  label: 'Mes siguiente',
                                  icon: Icons.chevron_right,
                                  onPressed: month.isBefore(currentMonth)
                                      ? () => setState(
                                          () => month = DateTime(
                                            month.year,
                                            month.month + 1,
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                            SizedBox(height: m.spaceM),
                            Text(
                              '$paidCount de ${weeks.length} semanas con pago registrado',
                              style: t.body,
                            ),
                            SizedBox(height: m.spaceL),
                            for (final week in weeks) ...[
                              _WeekCard(
                                week: week,
                                scheduledDate: PayrollWeek.scheduledDate(
                                  week,
                                  employee.diaPago,
                                ),
                                payment: byPeriod[PayrollWeek.dateKey(week)],
                                upcoming: week.isAfter(currentWeek),
                              ),
                              SizedBox(height: m.spaceM),
                            ],
                            if (legacy.isNotEmpty) ...[
                              SizedBox(height: m.spaceL),
                              Text(
                                'Pagos anteriores sin semana registrada',
                                style: t.text.titleLarge,
                              ),
                              SizedBox(height: m.spaceS),
                              for (final payment in legacy) ...[
                                ExquisssitaSurface(
                                  child: Text(
                                    '${CurrencyUtils.format(payment.montoCentavos)} · realizado el ${PayrollWeek.dateLabel(DateTime.parse(payment.fechaPago))}. La semana no se guardaba en la versión anterior.',
                                    style: t.body,
                                  ),
                                ),
                                SizedBox(height: m.spaceM),
                              ],
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.week,
    required this.scheduledDate,
    required this.payment,
    required this.upcoming,
  });

  final DateTime week;
  final DateTime scheduledDate;
  final HistorialPagosEmpleadosTableData? payment;
  final bool upcoming;

  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    final paid = payment;
    return ExquisssitaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: m.spaceS,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(PayrollWeek.label(week), style: t.text.titleLarge),
              ),
              ExquisssitaStatusBadge(
                label: paid != null
                    ? 'Pagada'
                    : upcoming
                    ? 'Próxima'
                    : 'Pendiente',
                icon: paid != null
                    ? Icons.check_circle_outline
                    : Icons.schedule_outlined,
              ),
            ],
          ),
          Text(PayrollWeek.rangeLabel(week), style: t.body),
          Text(
            'Día programado: ${PayrollWeek.dateLabel(paid?.fechaProgramada == null ? scheduledDate : DateTime.parse(paid!.fechaProgramada!))}',
            style: t.body,
          ),
          if (paid != null) ...[
            Text(
              'Realizado: ${PayrollWeek.dateLabel(DateTime.parse(paid.fechaPago))}',
              style: t.body,
            ),
            Text(
              'Monto: ${CurrencyUtils.format(paid.montoCentavos)}',
              style: t.body,
            ),
            if (paid.notas != null && paid.notas!.isNotEmpty)
              Text('Notas: ${paid.notas}', style: t.body),
          ],
        ],
      ),
    );
  }
}

List<DateTime> _weeksInMonth(DateTime month) {
  final firstMonday = PayrollWeek.startOf(DateTime(month.year, month.month));
  return [
    for (
      var week = firstMonday;
      week.isBefore(DateTime(month.year, month.month + 1));
      week = week.add(const Duration(days: 7))
    )
      if (week.add(const Duration(days: 3)).month == month.month) week,
  ];
}

String _weekdayName(int day) => const [
  '?',
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
][day.clamp(1, 7)];
