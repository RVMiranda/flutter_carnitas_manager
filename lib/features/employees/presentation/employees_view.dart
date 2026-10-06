import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/exquisssita_tokens.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/local/database/app_database.dart';
import '../../../shared/widgets/exquisssita_components.dart';
import '../../auth/presentation/view_models/auth_vm.dart';
import '../domain/payroll_models.dart';
import 'employee_payment_history_view.dart';
import 'employee_view_model.dart';

class EmployeesView extends ConsumerWidget {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    return role.when(
      loading: () => const Center(child: ExquisssitaSkeleton()),
      error: (_, _) => const ExquisssitaErrorState(
        message: 'No fue posible verificar permisos.',
      ),
      data: (value) => PayrollRules.canManage(value)
          ? _EmployeesContent(role: value)
          : const ExquisssitaEmptyState(
              message: 'No tienes permiso para gestionar empleados.',
            ),
    );
  }
}

class _EmployeesContent extends ConsumerWidget {
  const _EmployeesContent({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(employeeViewModelProvider(role));
    final vm = ref.read(employeeViewModelProvider(role).notifier);
    final t = context.exq;
    final m = t.metrics;
    final today = DateTime.now();
    final currentPeriod = PayrollWeek.dateKey(PayrollWeek.startOf(today));
    final paidThisWeek = state.payments
        .where((payment) => payment.periodoInicio == currentPeriod)
        .map((payment) => payment.empleadoId)
        .toSet();
    final due = state.employees
        .where((e) =>
            e.activo &&
            PayrollRules.isPayDay(today, e.diaPago) &&
            !paidThisWeek.contains(e.id))
        .toList();

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(m.spaceXl),
                  child: Center(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Empleados y nómina',
                        style: t.heading,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: state.loading
                      ? const ExquisssitaSkeleton()
                      : state.error != null && state.employees.isEmpty
                      ? const ExquisssitaErrorState()
                      : ListView(
                          padding: EdgeInsets.fromLTRB(
                            m.spaceXl,
                            m.spaceS,
                            m.spaceXl,
                            m.target + m.section + m.spaceXxl,
                          ),
                          children: [
                            if (due.isNotEmpty) ...[
                              ExquisssitaSurface(
                                child: Text(
                                  'Hoy corresponde pagar a: ${due.map((e) => '${e.nombre} ${e.apellido}').join(', ')}',
                                  style: t.text.titleLarge,
                                ),
                              ),
                              SizedBox(height: m.spaceL),
                            ],
                            if (state.employees.isEmpty)
                              const ExquisssitaEmptyState(
                                message: 'No hay empleados registrados.',
                              ),
                            for (final employee in state.employees) ...[
                              _EmployeeCard(
                                employee: employee,
                                onEdit: () =>
                                    _showEditor(context, vm, employee),
                                onHistory: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => EmployeePaymentHistoryView(
                                      role: role,
                                      employeeId: employee.id,
                                    ),
                                  ),
                                ),
                                onPay: employee.activo
                                    ? () => _showPayment(context, vm, employee)
                                    : null,
                              ),
                              SizedBox(height: m.spaceM),
                            ],
                          ],
                        ),
                ),
              ],
            ),
            Positioned(
              left: m.spaceXl,
              right: m.spaceXl,
              bottom: m.spaceL,
              child: Center(
                child: ExquisssitaAction(
                  key: const ValueKey('new-employee'),
                  label: 'Nuevo empleado',
                  icon: Icons.add_outlined,
                  onPressed: () => _showEditor(context, vm, null),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    EmployeeViewModel vm,
    EmpleadosTableData? employee,
  ) => showExquisssitaModal<void>(
    context: context,
    builder: (_) => _EmployeeEditor(vm: vm, employee: employee),
  );

  Future<void> _showPayment(
    BuildContext context,
    EmployeeViewModel vm,
    EmpleadosTableData employee,
  ) => showExquisssitaModal<void>(
    context: context,
    builder: (_) => _PaymentEditor(vm: vm, employee: employee),
  );
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({
    required this.employee,
    required this.onEdit,
    required this.onHistory,
    this.onPay,
  });

  final EmpleadosTableData employee;
  final VoidCallback onEdit;
  final VoidCallback onHistory;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    return ExquisssitaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: m.spaceM,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${employee.nombre} ${employee.apellido}',
                      style: t.text.titleLarge,
                    ),
                    Text(
                      '${_weekdayName(employee.diaPago)} · ${CurrencyUtils.format(employee.salarioCentavos)} · ${employee.activo ? 'Activo' : 'Inactivo'}',
                      style: t.body,
                    ),
                  ],
                ),
              ),
              ExquisssitaIconAction(
                key: ValueKey('edit-employee-${employee.id}'),
                label: 'Editar ${employee.nombre} ${employee.apellido}',
                icon: Icons.edit_outlined,
                onPressed: onEdit,
              ),
            ],
          ),
          if (onPay != null)
            ExquisssitaAction(
              key: ValueKey('pay-employee-${employee.id}'),
              primary: false,
              label: 'Registrar pago',
              icon: Icons.payments_outlined,
              onPressed: onPay,
            ),
          ExquisssitaAction(
            key: ValueKey('history-employee-${employee.id}'),
            primary: false,
            label: 'Historial de pagos',
            icon: Icons.history_outlined,
            onPressed: onHistory,
          ),
        ],
      ),
    );
  }
}

class _EmployeeEditor extends StatefulWidget {
  const _EmployeeEditor({required this.vm, this.employee});

  final EmployeeViewModel vm;
  final EmpleadosTableData? employee;

  @override
  State<_EmployeeEditor> createState() => _EmployeeEditorState();
}

class _EmployeeEditorState extends State<_EmployeeEditor> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController first;
  late final TextEditingController last;
  late final TextEditingController phone;
  late final TextEditingController salary;
  late int payDay;
  late bool active;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    first = TextEditingController(text: employee?.nombre ?? '');
    last = TextEditingController(text: employee?.apellido ?? '');
    phone = TextEditingController(text: employee?.telefono ?? '');
    salary = TextEditingController(
      text: employee == null
          ? ''
          : CurrencyUtils.format(
              employee.salarioCentavos,
            ).replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    payDay = employee?.diaPago ?? 1;
    active = employee?.activo ?? true;
  }

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    phone.dispose();
    salary.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) return;
    setState(() => saving = true);
    var saved = false;
    try {
      await widget.vm.save(
        EmployeeDraft(
          id: widget.employee?.id,
          firstName: first.text,
          lastName: last.text,
          phone: phone.text,
          salaryPesos: salary.text,
          payDay: payDay,
          active: active,
        ),
      );
      saved = true;
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) _showError(context, 'No fue posible guardar el empleado.');
    } finally {
      if (mounted && !saved) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.exq;
    final m = t.metrics;
    return ExquisssitaModal(
      title: widget.employee == null ? 'Nuevo empleado' : 'Editar empleado',
      equalActions: true,
      actions: [
        _ModalAction(
          label: 'Cancelar',
          key: const ValueKey('cancel-employee'),
          onPressed: () => Navigator.pop(context),
          primary: false,
        ),
        _ModalAction(
          label: 'Guardar',
          key: const ValueKey('save-employee'),
          onPressed: save,
          busy: saving,
        ),
      ],
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: m.spaceL,
          children: [
            _LabeledField(
              label: 'Nombre',
              controller: first,
              validator: PayrollRules.name,
            ),
            _LabeledField(
              label: 'Apellido',
              controller: last,
              validator: PayrollRules.name,
            ),
            _LabeledField(
              label: 'Teléfono',
              controller: phone,
              keyboardType: TextInputType.phone,
            ),
            _LabeledField(
              label: 'Salario semanal (pesos)',
              controller: salary,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: PayrollRules.salary,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: m.spaceS,
              children: [
                Text('Día de pago semanal', style: t.text.titleLarge),
                DropdownButtonFormField<int>(
                  key: const ValueKey('employee-pay-day'),
                  initialValue: payDay,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  items: [
                    for (var day = 1; day <= 7; day++)
                      DropdownMenuItem(
                        value: day,
                        child: Text(_weekdayName(day)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => payDay = value);
                  },
                ),
              ],
            ),
            if (widget.employee != null)
              ExquisssitaAction(
                primary: false,
                label: active ? 'Empleado activo' : 'Empleado inactivo',
                onPressed: () => setState(() => active = !active),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentEditor extends StatefulWidget {
  const _PaymentEditor({required this.vm, required this.employee});

  final EmployeeViewModel vm;
  final EmpleadosTableData employee;

  @override
  State<_PaymentEditor> createState() => _PaymentEditorState();
}

class _PaymentEditorState extends State<_PaymentEditor> {
  final notes = TextEditingController();
  late DateTime periodStart;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    periodStart = PayrollWeek.startOf(DateTime.now());
  }

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (saving) return;
    setState(() => saving = true);
    var registered = false;
    try {
      await widget.vm.pay(
        widget.employee,
        DateTime.now(),
        notes.text,
        periodStart: periodStart,
      );
      registered = true;
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        _showError(
          context,
          'No fue posible registrar el pago. Comprueba si esa semana ya está pagada.',
        );
      }
    } finally {
      if (mounted && !registered) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ExquisssitaModal(
    title: 'Pagar a ${widget.employee.nombre}',
    equalActions: true,
    actions: [
      _ModalAction(
        label: 'Cancelar',
        primary: false,
        onPressed: () => Navigator.pop(context),
      ),
      _ModalAction(label: 'Registrar', onPressed: register, busy: saving),
    ],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.exq.metrics.spaceL,
      children: [
        Text(
          'Monto: ${CurrencyUtils.format(widget.employee.salarioCentavos)}',
          style: context.exq.text.titleLarge,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.exq.metrics.spaceS,
          children: [
            Text('Semana correspondiente', style: context.exq.text.titleLarge),
            DropdownButtonFormField<String>(
              key: const ValueKey('payment-week'),
              initialValue: PayrollWeek.dateKey(periodStart),
              isExpanded: true,
              decoration: const InputDecoration(),
              items: [
                for (var offset = 0; offset < 12; offset++)
                  DropdownMenuItem(
                    value: PayrollWeek.dateKey(
                      PayrollWeek.startOf(
                        DateTime.now(),
                      ).subtract(Duration(days: offset * 7)),
                    ),
                    child: Text(
                      PayrollWeek.label(
                        PayrollWeek.startOf(
                          DateTime.now(),
                        ).subtract(Duration(days: offset * 7)),
                      ),
                    ),
                  ),
              ],
              onChanged: saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => periodStart = DateTime.parse(value));
                      }
                    },
            ),
            Text(
              'Pago programado: ${PayrollWeek.dateLabel(PayrollWeek.scheduledDate(periodStart, widget.employee.diaPago))}',
              style: context.exq.body,
            ),
          ],
        ),
        _LabeledField(label: 'Notas (opcional)', controller: notes),
      ],
    ),
  );
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: context.exq.metrics.spaceS,
    children: [
      Text(label, style: context.exq.text.titleLarge),
      ExquisssitaFormField(
        label: label,
        showLabel: false,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
      ),
    ],
  );
}

class _ModalAction extends StatelessWidget {
  const _ModalAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.busy = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool busy;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: context.exq.metrics.target + context.exq.metrics.spaceL,
    child: ExquisssitaAction(
      label: label,
      onPressed: onPressed,
      primary: primary,
      busy: busy,
    ),
  );
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
