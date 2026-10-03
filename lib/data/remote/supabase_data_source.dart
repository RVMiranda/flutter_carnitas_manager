import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDataSource {
  SupabaseDataSource(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> registerVisitQr(String token) async {
    final result = await _client.rpc(
      'registrar_visita_qr',
      params: {'p_qr_token': token},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  static const _allowedTables = {
    'clientes',
    'empleados',
    'productos',
    'mesas',
    'promociones',
    'ordenes',
    'detalle_orden',
    'transacciones',
    'pago_detalles',
    'movimientos_inventario',
    'visitas_clientes',
    'auditoria_eventos',
    'historial_pagos_empleados',
  };

  Future<void> apply({
    required String entity,
    required String operation,
    required Map<String, dynamic> payload,
    required String entityId,
  }) async {
    if (entity == 'registrar_pago' ||
        entity == 'registrar_movimiento_inventario') {
      await _client.rpc(entity, params: payload);
      return;
    }
    if (!_allowedTables.contains(entity)) {
      throw ArgumentError('Entidad no permitida para sincronización: $entity');
    }
    final table = _client.from(entity);
    switch (operation) {
      case 'INSERT':
        await table.upsert(payload, onConflict: 'id');
      case 'UPDATE':
        await table.update(payload).eq('id', entityId);
      case 'DELETE':
        await table.delete().eq('id', entityId);
      default:
        throw ArgumentError('Operación no permitida: $operation');
    }
  }
}
