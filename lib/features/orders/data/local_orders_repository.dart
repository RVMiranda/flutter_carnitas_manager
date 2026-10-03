import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/local/database/local_persistence.dart';
import '../domain/order_models.dart';

class LocalOrdersRepository implements OrdersRepository {
  LocalOrdersRepository(this.db);
  final AppDatabase db;
  final _uuid = const Uuid();

  @override
  Stream<List<TableSummary>> watchTables() => (db.select(db.mesasTable)..orderBy([(t) => OrderingTerm(expression: t.numeroMesa)])).watch().map((rows) => rows.map((r) => TableSummary(id: r.id, number: r.numeroMesa, status: r.estado)).toList(growable: false));

  @override
  Stream<List<OrderSummary>> watchOpenOrders() => (db.select(db.ordenesTable)..where((t) => t.estado.equals('Abierta'))..orderBy([(t) => OrderingTerm.desc(t.fechaApertura)])).watch().asyncMap((rows) async => Future.wait(rows.map(_mapOrder)));

  @override
  Stream<OrderSummary?> watchOrder(String orderId) => (db.select(db.ordenesTable)..where((t) => t.id.equals(orderId))).watchSingleOrNull().asyncMap((row) async => row == null ? null : _mapOrder(row));

  @override
  Future<OrderSummary> openOrder({String? tableId, required ServiceType serviceType, String? notes}) async {
    if (serviceType == ServiceType.table && tableId == null) throw ArgumentError('tableId es requerido para una orden de mesa');
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final type = serviceType == ServiceType.table ? 'Mesa' : 'Para llevar';
    await db.transaction(() async {
      if (tableId != null) {
        final existing = await (db.select(db.ordenesTable)..where((t) => t.mesaId.equals(tableId) & t.estado.equals('Abierta'))).getSingleOrNull();
        if (existing != null) throw StateError('La mesa ya tiene una orden abierta');
        await (db.update(db.mesasTable)..where((t) => t.id.equals(tableId))).write(const MesasTableCompanion(estado: Value('Ocupada')));
      }
      await db.into(db.ordenesTable).insert(OrdenesTableCompanion.insert(id: id, mesaId: Value(tableId), tipoServicio: type, notas: Value(notes), fechaApertura: now, createdAt: now, updatedAt: now));
      await _enqueue('INSERT', 'ordenes', id, {'id': id, 'mesa_id': tableId, 'tipo_servicio': type, 'estado': 'Abierta', 'fecha_apertura': now, 'notas': notes});
    });
    return OrderSummary(id: id, serviceType: serviceType, status: OrderStatus.open, tableId: tableId, notes: notes);
  }

  @override
  Future<void> addProduct({required String orderId, required String productId, required int quantity, String? notes}) async {
    if (quantity <= 0) throw ArgumentError('La cantidad debe ser mayor que cero');
    final product = await (db.select(db.productosTable)..where((t) => t.id.equals(productId) & t.activo.equals(true))).getSingleOrNull();
    if (product == null) throw StateError('Producto no disponible');
    final order = await (db.select(db.ordenesTable)..where((t) => t.id.equals(orderId) & t.estado.equals('Abierta'))).getSingleOrNull();
    if (order == null) throw StateError('La orden no está abierta');
    final detailId = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.detalleOrdenTable).insert(DetalleOrdenTableCompanion.insert(id: detailId, ordenId: orderId, productoId: productId, cantidad: quantity, precioUnitarioCentavos: product.precioCentavos, notas: Value(notes), createdAt: now, updatedAt: now));
      await _enqueue('INSERT', 'detalle_orden', detailId, {'id': detailId, 'orden_id': orderId, 'producto_id': productId, 'cantidad': quantity, 'precio_unitario_centavos': product.precioCentavos, 'notas': notes});
    });
  }

  @override
  Future<void> updateQuantity({required String detailId, required int quantity}) async {
    if (quantity <= 0) throw ArgumentError('La cantidad debe ser mayor que cero');
    final now = DateTime.now().millisecondsSinceEpoch;
    final changed = await (db.update(db.detalleOrdenTable)..where((t) => t.id.equals(detailId))).write(DetalleOrdenTableCompanion(cantidad: Value(quantity), updatedAt: Value(now)));
    if (changed == 0) throw StateError('Detalle no encontrado');
    await _enqueue('UPDATE', 'detalle_orden', detailId, {'id': detailId, 'cantidad': quantity, 'updated_at': now});
  }

  @override
  Future<void> updateNotes({required String orderId, required String? notes}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final changed = await (db.update(db.ordenesTable)..where((t) => t.id.equals(orderId) & t.estado.equals('Abierta'))).write(OrdenesTableCompanion(notas: Value(notes), updatedAt: Value(now)));
    if (changed == 0) throw StateError('La orden no está abierta');
    await _enqueue('UPDATE', 'ordenes', orderId, {'id': orderId, 'notas': notes, 'updated_at': now});
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      final order = await (db.select(db.ordenesTable)..where((t) => t.id.equals(orderId) & t.estado.equals('Abierta'))).getSingleOrNull();
      if (order == null) throw StateError('La orden no está abierta');
      await (db.update(db.ordenesTable)..where((t) => t.id.equals(orderId))).write(OrdenesTableCompanion(estado: const Value('Cancelada'), fechaCierre: Value(now), updatedAt: Value(now)));
      if (order.mesaId != null) await (db.update(db.mesasTable)..where((t) => t.id.equals(order.mesaId!))).write(const MesasTableCompanion(estado: Value('Libre')));
      await _enqueue('UPDATE', 'ordenes', orderId, {'id': orderId, 'estado': 'Cancelada', 'fecha_cierre': now});
    });
  }

  Future<void> _enqueue(String operation, String entity, String entityId, Map<String, Object?> payload) => db.into(db.syncQueueTable).insert(SyncQueueTableCompanion.insert(id: _uuid.v4(), entity: entity, entityId: entityId, operation: operation, payload: LocalPersistence.encodePayload(payload), idempotencyKey: _uuid.v4(), createdAt: DateTime.now().millisecondsSinceEpoch));
  Future<OrderSummary> _mapOrder(OrdenesTableData row) async {
    final details = await (db.select(db.detalleOrdenTable)..where((t) => t.ordenId.equals(row.id))).get();
    final products = await (db.select(db.productosTable)..where((t) => t.id.isIn(details.map((d) => d.productoId)))).get();
    final byId = {for (final p in products) p.id: p};
    final lines = details.map((d) => OrderLine(id: d.id, productId: d.productoId, name: byId[d.productoId]?.nombre ?? 'Producto', quantity: d.cantidad, unitPriceCents: d.precioUnitarioCentavos, notes: d.notas)).toList(growable: false);
    return OrderSummary(id: row.id, serviceType: row.tipoServicio == 'Mesa' ? ServiceType.table : ServiceType.takeaway, status: row.estado == 'Abierta' ? OrderStatus.open : row.estado == 'Cancelada' ? OrderStatus.cancelled : OrderStatus.closed, tableId: row.mesaId, notes: row.notas, lines: lines);
  }
}
