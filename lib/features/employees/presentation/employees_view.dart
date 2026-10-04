import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/core/utils/currency_utils.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';
import '../domain/payroll_models.dart';
import 'employee_view_model.dart';

class EmployeesView extends ConsumerWidget {
  const EmployeesView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    return role.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) =>
          const Center(child: Text('No fue posible verificar permisos.')),
      data: (value) => PayrollRules.canManage(value)
          ? _EmployeesContent(role: value)
          : const Center(
              child: Text('No tienes permiso para gestionar empleados.'),
            ),
    );
  }
}

class _EmployeesContent extends ConsumerStatefulWidget {
  const _EmployeesContent({required this.role});
  final AppRole role;
  @override
  ConsumerState<_EmployeesContent> createState() => _EmployeesContentState();
}

class _EmployeesContentState extends ConsumerState<_EmployeesContent> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController(),
      _last = TextEditingController(),
      _phone = TextEditingController(),
      _salary = TextEditingController(),
      _day = TextEditingController();
  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _salary.dispose();
    _day.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeViewModelProvider(widget.role));
    final vm = ref.read(employeeViewModelProvider(widget.role).notifier);
    final today = DateTime.now();
    final due = state.employees.where((e) {
      return e.activo && PayrollRules.isPayDay(today, e.diaPago);
    }).toList();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Empleados y nómina',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showForm(vm),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo empleado'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (due.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Hoy corresponde pagar a: ${due.map((e) => '${e.nombre} ${e.apellido}').join(', ')}',
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: state.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.employees.isEmpty
                    ? const Center(child: Text('No hay empleados registrados.'))
                    : ListView.builder(
                        itemCount: state.employees.length,
                        itemBuilder: (_, index) {
                          final employee = state.employees[index];
                          return ListTile(
                            title: Text(
                              '${employee.nombre} ${employee.apellido}',
                            ),
                            subtitle: Text(
                              '${_weekdayName(employee.diaPago)} · ${CurrencyUtils.format(employee.salarioCentavos)} · ${employee.activo ? 'Activo' : 'Inactivo'}',
                            ),
                            trailing: employee.activo
                                ? TextButton(
                                    onPressed: () => _pay(vm, employee),
                                    child: const Text('Registrar pago'),
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pay(EmployeeViewModel vm, EmpleadosTableData employee) async {
    final notes = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Pagar a ${employee.nombre}'),
        content: TextField(
          controller: notes,
          decoration: const InputDecoration(labelText: 'Notas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await vm.pay(employee, DateTime.now(), notes.text);
              if (dialog.mounted) Navigator.pop(dialog);
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
    notes.dispose();
  }

  Future<void> _showForm(EmployeeViewModel vm) async {
    _first.clear();
    _last.clear();
    _phone.clear();
    _salary.clear();
    _day.clear();
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Nuevo empleado'),
        content: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _first,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: PayrollRules.name,
                ),
                TextFormField(
                  controller: _last,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: PayrollRules.name,
                ),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                TextFormField(
                  controller: _salary,
                  decoration: const InputDecoration(labelText: 'Salario semanal (pesos)', helperText: 'Ejemplo: 1000 o 1000.50'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: PayrollRules.salary,
                ),
                DropdownButtonFormField<int>(
                  initialValue: 1,
                  decoration: const InputDecoration(labelText: 'Día de pago semanal'),
                  items: const [DropdownMenuItem(value: 1, child: Text('Lunes')), DropdownMenuItem(value: 2, child: Text('Martes')), DropdownMenuItem(value: 3, child: Text('Miércoles')), DropdownMenuItem(value: 4, child: Text('Jueves')), DropdownMenuItem(value: 5, child: Text('Viernes')), DropdownMenuItem(value: 6, child: Text('Sábado')), DropdownMenuItem(value: 7, child: Text('Domingo'))],
                  onChanged: (value) => _day.text = '${value ?? 1}',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!_form.currentState!.validate()) return;
              await vm.save(
                EmployeeDraft(
                  firstName: _first.text,
                  lastName: _last.text,
                  phone: _phone.text,
                  salaryPesos: _salary.text,
                  payDay: int.tryParse(_day.text) ?? 1,
                  active: true,
                ),
              );
              if (dialog.mounted) Navigator.pop(dialog);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  String _weekdayName(int day) => const ['?', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'][day.clamp(1, 7)];
}
