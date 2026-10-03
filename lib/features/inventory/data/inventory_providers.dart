import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:exquisssita_manager/data/local/database/database_provider.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'local_inventory_repository.dart';

part 'inventory_providers.g.dart';

@Riverpod(keepAlive: true)
InventoryRepository inventoryRepository(Ref ref) =>
    LocalInventoryRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<ProductosTableData>> lowStockProducts(Ref ref) =>
    ref.watch(inventoryRepositoryProvider).watchLowStock();
