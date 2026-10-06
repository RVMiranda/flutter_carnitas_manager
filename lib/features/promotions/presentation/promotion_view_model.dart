import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/promotion_providers.dart';
import '../data/promotion_repository.dart';

class PromotionUiState {
  const PromotionUiState({this.saving = false, this.saved = false, this.error});

  final bool saving;
  final bool saved;
  final Object? error;
}

final promotionViewModelProvider =
    StateNotifierProvider.autoDispose<PromotionViewModel, PromotionUiState>(
      (ref) => PromotionViewModel(ref.watch(promotionRepositoryProvider)),
    );

class PromotionViewModel extends StateNotifier<PromotionUiState> {
  PromotionViewModel(this.repository) : super(const PromotionUiState());

  final PromotionRepository repository;

  Future<void> setActive(String id, bool active) async {
    if (state.saving) return;
    state = const PromotionUiState(saving: true);
    try {
      await repository.setActive(id, active);
      state = const PromotionUiState(saved: true);
    } catch (error) {
      state = PromotionUiState(error: error);
      rethrow;
    }
  }
}
