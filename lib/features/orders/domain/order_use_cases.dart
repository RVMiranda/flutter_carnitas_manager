import 'order_models.dart';

class OpenOrderUseCase {
  const OpenOrderUseCase(this.repository);
  final OrdersRepository repository;
  Future<OrderSummary> call({String? tableId, required ServiceType serviceType, String? notes}) => repository.openOrder(tableId: tableId, serviceType: serviceType, notes: notes);
}

class AddOrderProductUseCase {
  const AddOrderProductUseCase(this.repository);
  final OrdersRepository repository;
  Future<void> call({required String orderId, required String productId, required int quantity, String? notes}) => repository.addProduct(orderId: orderId, productId: productId, quantity: quantity, notes: notes);
}
