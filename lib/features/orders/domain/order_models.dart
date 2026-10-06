enum ServiceType { table, takeaway }

enum OrderStatus { open, cancelled, closed }

class TableSummary {
  const TableSummary({
    required this.id,
    required this.number,
    required this.status,
    this.pendingSync = false,
    this.syncFailed = false,
  });
  final String id;
  final String number;
  final String status;
  final bool pendingSync;
  final bool syncFailed;
  bool get available => status == 'Libre';
}

class OrderLine {
  const OrderLine({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
    this.notes,
  });
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final int unitPriceCents;
  final String? notes;
  int get subtotalCents => quantity * unitPriceCents;
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.serviceType,
    required this.status,
    this.tableId,
    this.tableNumber,
    this.notes,
    this.lines = const [],
    this.pendingSync = false,
    this.syncFailed = false,
  });
  final String id;
  final ServiceType serviceType;
  final OrderStatus status;
  final String? tableId;
  final String? tableNumber;
  final String? notes;
  final List<OrderLine> lines;
  final bool pendingSync, syncFailed;
  int get totalCents => lines.fold(0, (sum, line) => sum + line.subtotalCents);
}

abstract interface class OrdersRepository {
  Future<int> retryLegacyOperations(String orderId);
  Future<void> createTable(String number);
  Future<OrderSummary> openOrResumeOrder({
    String? tableId,
    required ServiceType serviceType,
  });
  Stream<List<TableSummary>> watchTables();
  Stream<List<OrderSummary>> watchOpenOrders();
  Stream<OrderSummary?> watchOrder(String orderId);
  Future<OrderSummary> openOrder({
    String? tableId,
    required ServiceType serviceType,
    String? notes,
  });
  Future<void> addProduct({
    required String orderId,
    required String productId,
    required int quantity,
    String? notes,
  });
  Future<void> updateQuantity({
    required String detailId,
    required int quantity,
  });
  Future<void> updateNotes({required String orderId, required String? notes});
  Future<void> cancelOrder(String orderId);
}
