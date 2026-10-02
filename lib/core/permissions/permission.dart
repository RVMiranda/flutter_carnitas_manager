/// Capacidades de la aplicación administrativa.
enum Permission {
  manageEmployees,
  manageInventory,
  managePromotions,
  closeCashRegister,
  manageOrders,
  processPayments,
  scanLoyalty,
}

enum AppRole { admin, employee }

extension AppRolePermissions on AppRole {
  bool can(Permission permission) {
    if (this == AppRole.admin) return true;
    return switch (permission) {
      Permission.manageEmployees ||
      Permission.managePromotions ||
      Permission.closeCashRegister => false,
      _ => true,
    };
  }
}
