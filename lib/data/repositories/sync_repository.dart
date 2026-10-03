import 'dart:convert';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/remote/supabase_data_source.dart';

/// Contrato de persistencia remota usado por el worker.
/// Mantiene Supabase fuera de la capa de coordinación y facilita pruebas.
abstract interface class SyncRepository {
  Future<void> push(SyncQueueTableData operation);
}

extension SyncQueuePayload on SyncQueueTableData {
  Map<String, dynamic> get payloadMap =>
      jsonDecode(payload) as Map<String, dynamic>;
}

class SupabaseSyncRepository implements SyncRepository {
  SupabaseSyncRepository(this._remote);
  final SupabaseDataSource _remote;

  @override
  Future<void> push(SyncQueueTableData operation) => _remote.apply(
    entity: operation.entity,
    operation: operation.operation,
    payload: operation.payloadMap,
    entityId: operation.entityId,
  );
}
