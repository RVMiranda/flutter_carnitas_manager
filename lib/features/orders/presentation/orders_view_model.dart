import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/orders_providers.dart';
import '../domain/order_models.dart';

final ordersViewModelProvider =
    NotifierProvider<OrdersViewModel, AsyncValue<void>>(OrdersViewModel.new);

class OrdersViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);
  OrdersRepository get repository => ref.read(ordersRepositoryProvider);
  Future<String> retryLegacy(String orderId) async {
    final count = await repository.retryLegacyOperations(orderId);
    return count > 0
        ? 'Operaciones anteriores pendientes de reenvío.'
        : 'No hay operaciones con formato anterior para reintentar. La sincronización requiere revisión.';
  }

  String get errorMessage {
    final error = state.error;
    if (error is ArgumentError) {
      return 'Ingresa un número de mesa entre 1 y 9999.';
    }
    if (error is StateError &&
        error.message == 'Ya existe una mesa con ese número.') {
      return error.message;
    }
    if (error is StateError &&
        error.message ==
            'La mesa no está libre y su orden no está disponible. Sincroniza antes de abrir otra.') {
      return error.message;
    }
    return 'No se pudo completar la operación. Intenta nuevamente.';
  }

  Future<OrderSummary?> open({
    String? tableId,
    required ServiceType type,
    String? notes,
  }) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final result = await repository.openOrResumeOrder(
        tableId: tableId,
        serviceType: type,
      );
      state = const AsyncData(null);
      return result;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      return null;
    }
  }

  Future<bool> createTable(String number) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      await repository.createTable(number);
      state = const AsyncData(null);
      return true;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      return false;
    }
  }

  Future<void> add({
    required String orderId,
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      await repository.addProduct(
        orderId: orderId,
        productId: productId,
        quantity: quantity,
        notes: notes,
      );
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> cancel(String id) async {
    state = const AsyncLoading();
    try {
      await repository.cancelOrder(id);
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> updateNotes(String orderId, String? notes) =>
      repository.updateNotes(orderId: orderId, notes: notes);
}
