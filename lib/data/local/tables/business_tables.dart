import 'package:drift/drift.dart';

/// Tablas locales del dominio administrativo. Los UUID se generan en el
/// dispositivo para permitir crear operaciones sin conexión.
class ClientesTable extends Table {
  @override
  String get tableName => 'clientes';
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get qrTokenHash => text().nullable()();
  TextColumn get nombre => text()();
  TextColumn get telefono => text().nullable()();
  IntColumn get visitasTotales => integer().withDefault(const Constant(0))();
  IntColumn get puntosLealtad => integer().withDefault(const Constant(0))();
  IntColumn get fechaRegistro => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'productos_activo_nombre', columns: {#activo, #nombre})
class ProductosTable extends Table {
  @override
  String get tableName => 'productos';
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  IntColumn get precioCentavos => integer()();
  TextColumn get categoria => text()();
  BoolColumn get controlaInventario =>
      boolean().withDefault(const Constant(false))();
  IntColumn get stockActual => integer().withDefault(const Constant(0))();
  IntColumn get stockMinimo => integer().withDefault(const Constant(0))();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (precio_centavos >= 0)',
    'CHECK (stock_actual >= 0)',
    'CHECK (stock_minimo >= 0)',
  ];
}

@TableIndex(name: 'ordenes_estado_apertura', columns: {#estado, #fechaApertura})
class OrdenesTable extends Table {
  @override
  String get tableName => 'ordenes';
  TextColumn get id => text()();
  TextColumn get mesaId => text().nullable()();
  TextColumn get clienteId => text().nullable()();
  TextColumn get tipoServicio => text()();
  TextColumn get estado => text().withDefault(const Constant('Abierta'))();
  IntColumn get fechaApertura => integer()();
  IntColumn get fechaCierre => integer().nullable()();
  TextColumn get notas => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    "CHECK (tipo_servicio IN ('Mesa', 'Para llevar'))",
  ];
}

@TableIndex(name: 'detalle_orden_orden', columns: {#ordenId})
class DetalleOrdenTable extends Table {
  @override
  String get tableName => 'detalle_orden';
  TextColumn get id => text()();
  TextColumn get ordenId => text()();
  TextColumn get productoId => text()();
  IntColumn get cantidad => integer()();
  IntColumn get precioUnitarioCentavos => integer()();
  TextColumn get estadoPago =>
      text().withDefault(const Constant('Pendiente'))();
  TextColumn get notas => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (cantidad > 0)',
    'CHECK (precio_unitario_centavos >= 0)',
  ];
}

@TableIndex(name: 'transacciones_fecha', columns: {#fecha})
class TransaccionesTable extends Table {
  @override
  String get tableName => 'transacciones';
  TextColumn get id => text()();
  TextColumn get ordenId => text()();
  IntColumn get montoCentavos => integer()();
  TextColumn get metodoPago => text()();
  IntColumn get fecha => integer()();
  TextColumn get idempotencyKey => text().unique()();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => ['CHECK (monto_centavos > 0)'];
}

class PagoDetallesTable extends Table {
  @override
  String get tableName => 'pago_detalles';
  TextColumn get id => text()();
  TextColumn get transaccionId => text()();
  TextColumn get detalleOrdenId => text()();
  IntColumn get cantidad => integer()();
  IntColumn get montoCentavos => integer()();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (cantidad > 0)',
    'CHECK (monto_centavos > 0)',
  ];
}

class MovimientosInventarioTable extends Table {
  @override
  String get tableName => 'movimientos_inventario';
  TextColumn get id => text()();
  TextColumn get productoId => text()();
  IntColumn get cantidad => integer()();
  TextColumn get tipo => text()();
  TextColumn get referenciaId => text().nullable()();
  TextColumn get notas => text().nullable()();
  TextColumn get creadoPor => text().nullable()();
  IntColumn get createdAt => integer()();
  TextColumn get idempotencyKey => text().unique()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => ['CHECK (cantidad > 0)'];
}

@TableIndex(name: 'visitas_usuario_fecha', columns: {#usuarioId, #fecha})
class VisitasClientesTable extends Table {
  @override
  String get tableName => 'visitas_clientes';
  TextColumn get id => text()();
  TextColumn get clienteId => text()();
  TextColumn get usuarioId => text().nullable()();
  TextColumn get fecha => text()();
  IntColumn get puntosOtorgados => integer().withDefault(const Constant(10))();
  TextColumn get registradoPor => text().nullable()();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => ['CHECK (puntos_otorgados >= 0)'];
}

class AuditoriaEventosTable extends Table {
  @override
  String get tableName => 'auditoria_eventos';
  TextColumn get id => text()();
  TextColumn get actorId => text().nullable()();
  TextColumn get entidad => text()();
  TextColumn get entidadId => text().nullable()();
  TextColumn get accion => text()();
  TextColumn get datosJson => text().withDefault(const Constant('{}'))();
  TextColumn get dispositivoId => text().nullable()();
  BoolColumn get offline => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class EmpleadosTable extends Table {
  @override
  String get tableName => 'empleados';
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get nombre => text()();
  TextColumn get apellido => text()();
  TextColumn get telefono => text().nullable()();
  IntColumn get salarioCentavos => integer()();
  IntColumn get diaPago => integer()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (salario_centavos >= 0)',
    'CHECK (dia_pago BETWEEN 1 AND 31)',
  ];
}

class PromocionesTable extends Table {
  @override
  String get tableName => 'promociones';
  TextColumn get id => text()();
  TextColumn get titulo => text()();
  TextColumn get descripcion => text()();
  TextColumn get imagenUrl => text().nullable()();
  IntColumn get fechaPublicacion => integer()();
  TextColumn get fechaVencimiento => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class VentaDiariaTable extends Table {
  @override
  String get tableName => 'venta_diaria';
  IntColumn get id => integer()();
  TextColumn get fecha => text()();
  IntColumn get totalEfectivoCentavos =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalTarjetaCentavos =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalOtroCentavos => integer().withDefault(const Constant(0))();
  IntColumn get totalGlobalCentavos => integer()();
  IntColumn get numOrdenes => integer().withDefault(const Constant(0))();
  IntColumn get horaCierre => integer()();
  TextColumn get cerradoPor => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (total_efectivo_centavos >= 0)',
    'CHECK (total_tarjeta_centavos >= 0)',
    'CHECK (total_otro_centavos >= 0)',
    'CHECK (total_global_centavos >= 0)',
    'CHECK (num_ordenes >= 0)',
  ];
}

class HistorialPagosEmpleadosTable extends Table {
  @override
  String get tableName => 'historial_pagos_empleados';
  TextColumn get id => text()();
  TextColumn get empleadoId => text()();
  IntColumn get montoCentavos => integer()();
  TextColumn get fechaPago => text()();
  TextColumn get notas => text().nullable()();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}
