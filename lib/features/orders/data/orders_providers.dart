import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database/database_provider.dart';
import '../domain/order_models.dart';
import 'local_orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => LocalOrdersRepository(ref.watch(appDatabaseProvider)),
);
final tablesProvider = StreamProvider<List<TableSummary>>(
  (ref) => ref.watch(ordersRepositoryProvider).watchTables(),
);
final openOrdersProvider = StreamProvider<List<OrderSummary>>(
  (ref) => ref.watch(ordersRepositoryProvider).watchOpenOrders(),
);
final orderProvider = StreamProvider.family<OrderSummary?, String>(
  (ref, id) => ref.watch(ordersRepositoryProvider).watchOrder(id),
);
