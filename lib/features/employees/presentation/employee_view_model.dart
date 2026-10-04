import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exquisssita_manager/core/permissions/permission.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/database_provider.dart';
import '../data/employee_repository.dart';
import '../domain/payroll_models.dart';

class EmployeeUiState {
  const EmployeeUiState({
    this.employees = const [],
    this.payments = const [],
    this.loading = true,
    this.saving = false,
    this.error,
  });
  final List<EmpleadosTableData> employees;
  final List<HistorialPagosEmpleadosTableData> payments;
  final bool loading;
  final bool saving;
  final String? error;
  EmployeeUiState copyWith({
    List<EmpleadosTableData>? employees,
    List<HistorialPagosEmpleadosTableData>? payments,
    bool? loading,
    bool? saving,
    String? error,
  }) => EmployeeUiState(
    employees: employees ?? this.employees,
    payments: payments ?? this.payments,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    error: error,
  );
}

class EmployeeViewModel extends StateNotifier<EmployeeUiState> {
  EmployeeViewModel(this.repo) : super(const EmployeeUiState()) {
    _a = repo.watchEmployees().listen(
      (v) => state = state.copyWith(employees: v, loading: false),
      onError: (Object e) =>
          state = state.copyWith(loading: false, error: e.toString()),
    );
    _b = repo.watchPayments().listen(
      (v) => state = state.copyWith(payments: v),
    );
  }
  final EmployeeRepository repo;
  late final StreamSubscription<List<EmpleadosTableData>> _a;
  late final StreamSubscription<List<HistorialPagosEmpleadosTableData>> _b;
  Future<void> save(EmployeeDraft draft) async {
    state = state.copyWith(saving: true);
    try {
      await repo.save(draft);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  Future<void> pay(EmpleadosTableData e, DateTime date, String notes) async {
    state = state.copyWith(saving: true);
    try {
      await repo.registerPayment(
        e.id,
        date,
        notes,
      );
    } catch (x) {
      state = state.copyWith(error: x.toString());
    } finally {
      state = state.copyWith(saving: false);
    }
  }

  @override
  void dispose() {
    _a.cancel();
    _b.cancel();
    super.dispose();
  }
}

final employeeViewModelProvider = StateNotifierProvider.autoDispose
    .family<EmployeeViewModel, EmployeeUiState, AppRole>(
      (ref, role) => EmployeeViewModel(
        LocalEmployeeRepository(ref.watch(appDatabaseProvider), role: role),
      ),
    );
