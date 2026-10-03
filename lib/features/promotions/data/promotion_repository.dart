import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/local/tables/sync_queue_table.dart';
import '../domain/promotion_models.dart';

abstract interface class PromotionRepository {
  Stream<List<PromocionesTableData>> watchAll();
  Future<void> save(PromotionDraft draft);
  Future<void> setActive(String id, bool active);
}

class LocalPromotionRepository implements PromotionRepository {
  LocalPromotionRepository(this._database);
  final AppDatabase _database;

  @override
  Stream<List<PromocionesTableData>> watchAll() => (_database.select(
    _database.promocionesTable,
  )..orderBy([(p) => OrderingTerm.desc(p.fechaPublicacion)])).watch();

  @override
  Future<void> save(PromotionDraft draft) async {
    draft.validate();
    final now = DateTime.now().millisecondsSinceEpoch;
    final payload = draft.toJson();
    final existing = await (_database.select(_database.promocionesTable)
          ..where((p) => p.id.equals(draft.id)))
        .getSingleOrNull();
    await _database.transaction(() async {
      await _database
          .into(_database.promocionesTable)
          .insertOnConflictUpdate(
            PromocionesTableCompanion.insert(
              id: draft.id,
              titulo: draft.title.trim(),
              descripcion: draft.description.trim(),
              imagenUrl: Value(draft.imageUrl),
              fechaPublicacion: draft.publishedAt.millisecondsSinceEpoch,
              fechaVencimiento: Value(
                draft.expiresAt?.toIso8601String().split('T').first,
              ),
              activo: Value(draft.active),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueue(
        draft.id,
        payload,
        now,
        operation: existing == null ? SyncOperation.insert : SyncOperation.update,
      );
    });
  }

  @override
  Future<void> setActive(String id, bool active) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final current = await (_database.select(
      _database.promocionesTable,
    )..where((p) => p.id.equals(id))).getSingle();
    final payload = {
      'id': id,
      'titulo': current.titulo,
      'descripcion': current.descripcion,
      'imagen_url': current.imagenUrl,
      'fecha_publicacion': DateTime.fromMillisecondsSinceEpoch(
        current.fechaPublicacion,
      ).toUtc().toIso8601String(),
      'fecha_vencimiento': current.fechaVencimiento,
      'activo': active,
    };
    await _database.transaction(() async {
      await (_database.update(
        _database.promocionesTable,
      )..where((p) => p.id.equals(id))).write(
        PromocionesTableCompanion(activo: Value(active), updatedAt: Value(now)),
      );
      await _enqueue(id, payload, now, operation: SyncOperation.update);
    });
  }

  Future<void> _enqueue(
    String id,
    Map<String, Object?> payload,
    int now, {
    required String operation,
  }) =>
      _database
          .into(_database.syncQueueTable)
          .insert(
            SyncQueueTableCompanion.insert(
              id: const Uuid().v4(),
              entity: 'promociones',
              entityId: id,
              operation: operation,
              payload: LocalPersistence.encodePayload(payload),
              idempotencyKey: const Uuid().v4(),
              createdAt: now,
            ),
          );
}
