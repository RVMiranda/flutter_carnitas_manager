import 'package:drift/drift.dart';

/// Tablas locales del dominio administrativo. Los UUID se generan en el
/// dispositivo para permitir crear operaciones sin conexión.
class ClientesTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
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

class ProductosTable extends Table {
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
}

class OrdenesTable extends Table {
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
}

class DetalleOrdenTable extends Table {
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
}

class TransaccionesTable extends Table {
  TextColumn get id => text()();
  TextColumn get ordenId => text()();
  IntColumn get montoCentavos => integer()();
  TextColumn get metodoPago => text()();
  IntColumn get fecha => integer()();
  TextColumn get idempotencyKey => text().unique()();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class PagoDetallesTable extends Table {
  TextColumn get id => text()();
  TextColumn get transaccionId => text()();
  TextColumn get detalleOrdenId => text()();
  IntColumn get cantidad => integer()();
  IntColumn get montoCentavos => integer()();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class MovimientosInventarioTable extends Table {
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
}

class VisitasClientesTable extends Table {
  TextColumn get id => text()();
  TextColumn get clienteId => text()();
  TextColumn get fecha => text()();
  IntColumn get puntosOtorgados => integer().withDefault(const Constant(10))();
  TextColumn get registradoPor => text().nullable()();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class AuditoriaEventosTable extends Table {
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
