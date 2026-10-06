import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/loyalty_providers.dart';
import 'qr_scan_coordinator.dart';
import '../domain/qr_models.dart';

class QrScanUiState {
  const QrScanUiState({this.processing = false, this.error});
  final bool processing;
  final String? error;
}

final qrScanViewModelProvider =
    StateNotifierProvider.autoDispose<QrScanViewModel, QrScanUiState>(
      (ref) => QrScanViewModel(
        QrScanCoordinator(ref.watch(loyaltyRepositoryProvider)),
      ),
    );

class QrScanViewModel extends StateNotifier<QrScanUiState> {
  QrScanViewModel(this.coordinator) : super(const QrScanUiState());
  final QrScanCoordinator coordinator;
  Future<LoyaltyVisitResult?> scan(String value) async {
    if (state.processing) return null;
    state = const QrScanUiState(processing: true);
    try {
      final result = await coordinator.handle(value);
      state = const QrScanUiState();
      return result;
    } catch (e) {
      state = const QrScanUiState(
        error:
            'No fue posible registrar la visita. Verifica el QR y tu conexión.',
      );
      rethrow;
    }
  }
}
