import 'package:drift/drift.dart';

/// Tabla de mesas en la base de datos local.
///
/// Replica la estructura de la tabla `mesas` en Supabase.
/// El campo [id] es UUID generado localmente antes de sincronizar.
class MesasTable extends Table {
  @override
  String get tableName => 'mesas';

  TextColumn get id => text()();
  TextColumn get numeroMesa => text()();
  TextColumn get estado => text().withDefault(const Constant('Libre'))();
  IntColumn get createdAt => integer()(); // Unix timestamp en ms
  IntColumn get updatedAt =>
      integer()(); // Unix timestamp en ms — para detección de conflictos
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Estados válidos de una mesa.
abstract final class MesaEstado {
  static const libre = 'Libre';
  static const ocupada = 'Ocupada';
  static const reservada = 'Reservada';
}
