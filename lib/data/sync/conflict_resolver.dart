enum ConflictDecision { applyServer, preserveLocal, review }

class ConflictResolver {
  const ConflictResolver();
  static const appendOnly = {
    'transacciones',
    'pago_detalles',
    'movimientos_inventario',
    'visitas_clientes',
    'auditoria_eventos',
    'historial_pagos_empleados',
    'venta_diaria',
  };
  static const versioned = {
    'mesas',
    'ordenes',
    'detalle_orden',
    'promociones',
    'empleados',
    'clientes',
    'productos',
  };

  ConflictDecision resolve({
    required String entity,
    required bool dirty,
    required int baseVersion,
    required int serverVersion,
  }) {
    if (!dirty) return ConflictDecision.applyServer;
    // No last-write-wins for staff/payroll or operational/financial data.
    return serverVersion == baseVersion
        ? ConflictDecision.preserveLocal
        : ConflictDecision.review;
  }
}
