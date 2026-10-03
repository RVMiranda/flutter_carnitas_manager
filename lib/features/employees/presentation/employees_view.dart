import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
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
      final date = PayrollRules.effectivePayDate(today, e.diaPago);
      return e.activo &&
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
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
                              'Día ${employee.diaPago} · ${employee.salarioCentavos} centavos · ${employee.activo ? 'Activo' : 'Inactivo'}',
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
                  decoration: const InputDecoration(
                    labelText: 'Salario en centavos',
                  ),
                  keyboardType: TextInputType.number,
                  validator: PayrollRules.salary,
                ),
                TextFormField(
                  controller: _day,
                  decoration: const InputDecoration(labelText: 'Día de pago'),
                  keyboardType: TextInputType.number,
                  validator: PayrollRules.payDay,
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
                  salaryCents: int.parse(_salary.text),
                  payDay: int.parse(_day.text),
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
}
