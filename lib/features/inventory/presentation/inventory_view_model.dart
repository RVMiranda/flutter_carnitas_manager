import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import '../data/inventory_providers.dart';
import '../data/local_inventory_repository.dart';
import '../domain/inventory_models.dart';

enum InventoryViewStatus {
  initial,
  loading,
  success,
  empty,
  error,
  offline,
  syncing,
}

class InventoryUiState {
  const InventoryUiState({
    this.products = const [],
    this.query = '',
    this.category,
    this.controlled,
    this.status = InventoryViewStatus.initial,
    this.error,
  });
  final List<ProductosTableData> products;
  final String query;
  final String? category;
  final bool? controlled;
  final InventoryViewStatus status;
  final String? error;
  InventoryUiState copyWith({
    List<ProductosTableData>? products,
    String? query,
    String? category,
    bool? controlled,
    InventoryViewStatus? status,
    String? error,
    bool clearCategory = false,
    bool clearControlled = false,
  }) => InventoryUiState(
    products: products ?? this.products,
    query: query ?? this.query,
    category: clearCategory ? null : category ?? this.category,
    controlled: clearControlled ? null : controlled ?? this.controlled,
    status: status ?? this.status,
    error: error,
  );
}

class InventoryViewModel extends StateNotifier<InventoryUiState> {
  InventoryViewModel(this._repository) : super(const InventoryUiState()) {
    _watch();
  }
  final InventoryRepository _repository;
  StreamSubscription<List<ProductosTableData>>? _subscription;
  void _watch() {
    _subscription?.cancel();
    state = state.copyWith(status: InventoryViewStatus.loading);
    _subscription = _repository
        .watchProducts(
          query: state.query,
          category: state.category,
          controlled: state.controlled,
        )
        .listen(
          (items) => state = state.copyWith(
            products: items,
            status: items.isEmpty
                ? InventoryViewStatus.empty
                : InventoryViewStatus.success,
          ),
          onError: (Object error) => state = state.copyWith(
            status: InventoryViewStatus.error,
            error: error.toString(),
          ),
        );
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);
    _watch();
  }

  void setCategory(String? value) {
    state = value == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: value);
    _watch();
  }

  void setControlled(bool? value) {
    state = value == null
        ? state.copyWith(clearControlled: true)
        : state.copyWith(controlled: value);
    _watch();
  }

  Future<void> save(ProductDraft draft) => _repository.saveProduct(draft);
  Future<void> deactivate(String id) => _repository.deactivateProduct(id);
  Future<void> registerMovement(InventoryMovementRequest request) =>
      _repository.register(request).then((_) {});
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final inventoryViewModelProvider =
    StateNotifierProvider.autoDispose<InventoryViewModel, InventoryUiState>((
      ref,
    ) {
      return InventoryViewModel(ref.watch(inventoryRepositoryProvider));
    });
