import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exquisssita_manager/core/errors/failure.dart';
import '../data/cash_register_providers.dart';
import '../domain/cash_register_models.dart';

class CashRegisterUiState { const CashRegisterUiState({this.closing = false, this.saved = false, this.failure}); final bool closing; final bool saved; final Failure? failure; }
final cashRegisterViewModelProvider = StateNotifierProvider.autoDispose.family<CashRegisterViewModel, CashRegisterUiState, DateTime>((ref, date) => CashRegisterViewModel(ref.watch(cashRegisterRepositoryProvider)));
class CashRegisterViewModel extends StateNotifier<CashRegisterUiState> { CashRegisterViewModel(this.repository) : super(const CashRegisterUiState()); final CashRegisterRepository repository; Future<void> close(DateTime date) async { if (state.closing) return; state = const CashRegisterUiState(closing: true); try { await repository.close(date); state = const CashRegisterUiState(saved: true); } on CashRegisterAlreadyClosedFailure catch (e) { state = CashRegisterUiState(failure: e); } catch (e) { state = CashRegisterUiState(failure: UnexpectedFailure(technicalDetails: e.toString())); } } }
