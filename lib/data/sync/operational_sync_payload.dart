/// Compatibility boundary for operational intents from older installed builds.
/// The persisted intent and idempotency key remain unchanged. Financial RPCs
/// are deliberately excluded from this conversion.
Map<String, dynamic> operationalSyncPayload(
  String entity,
  Map<String, dynamic> original,
) {
  final payload = Map<String, dynamic>.from(original);
  if (!{'mesas', 'ordenes', 'detalle_orden'}.contains(entity)) return payload;
  payload.remove('created_at');
  payload.remove('updated_at');
  if (entity == 'ordenes') {
    for (final key in ['fecha_apertura', 'fecha_cierre']) {
      if (payload[key] is int) {
        payload[key] = DateTime.fromMillisecondsSinceEpoch(
          payload[key] as int,
        ).toUtc().toIso8601String();
      }
    }
  }
  if (entity == 'detalle_orden' &&
      payload.containsKey('precio_unitario_centavos')) {
    payload['precio_unitario'] = payload.remove('precio_unitario_centavos');
  }
  return payload;
}

bool hasLegacyOperationalPayload(String entity, Map<String, dynamic> payload) =>
    {'mesas', 'ordenes', 'detalle_orden'}.contains(entity) &&
    (payload.containsKey('created_at') ||
        payload.containsKey('updated_at') ||
        (entity == 'ordenes' &&
            (payload['fecha_apertura'] is int ||
                payload['fecha_cierre'] is int)) ||
        (entity == 'detalle_orden' &&
            payload.containsKey('precio_unitario_centavos')));
