import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:exquisssita_manager/data/local/database/database_provider.dart';
import '../domain/cash_register_models.dart';
import 'local_cash_register_repository.dart';

part 'cash_register_providers.g.dart';

@Riverpod(keepAlive: true)
CashRegisterRepository cashRegisterRepository(Ref ref) =>
    LocalCashRegisterRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<CashRegisterSummary> cashRegisterSummary(Ref ref, DateTime date) =>
    ref.watch(cashRegisterRepositoryProvider).watchSummary(date);
