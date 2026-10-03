import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/orders_providers.dart';
import '../domain/order_models.dart';

final ordersViewModelProvider = NotifierProvider<OrdersViewModel, AsyncValue<void>>(OrdersViewModel.new);

class OrdersViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);
  OrdersRepository get repository => ref.read(ordersRepositoryProvider);
  Future<OrderSummary?> open({String? tableId, required ServiceType type, String? notes}) async {
    state = const AsyncLoading();
    try {
      final result = await repository.openOrder(tableId: tableId, serviceType: type, notes: notes);
      state = const AsyncData(null);
      return result;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      return null;
    }
  }
  Future<void> add({required String orderId, required String productId, required int quantity, String? notes}) async {
    state = const AsyncLoading();
    try { await repository.addProduct(orderId: orderId, productId: productId, quantity: quantity, notes: notes); state = const AsyncData(null); } catch (error, stack) { state = AsyncError(error, stack); }
  }
  Future<void> cancel(String id) async {
    state = const AsyncLoading();
    try { await repository.cancelOrder(id); state = const AsyncData(null); } catch (error, stack) { state = AsyncError(error, stack); }
  }

  Future<void> updateNotes(String orderId, String? notes) => repository.updateNotes(orderId: orderId, notes: notes);
}
