import 'package:exquisssita_manager/data/remote/supabase_data_source.dart';
import '../domain/qr_models.dart';

abstract interface class LoyaltyRepository {
  Future<LoyaltyVisitResult> registerVisit(QrCustomerPayload payload);
}

class SupabaseLoyaltyRepository implements LoyaltyRepository {
  SupabaseLoyaltyRepository(this._remote);
  final SupabaseDataSource _remote;

  @override
  Future<LoyaltyVisitResult> registerVisit(QrCustomerPayload payload) async {
    final result = await _remote.registerVisitQr(payload.token);
    return LoyaltyVisitResult(
      registered: result['registered'] == true,
      alreadyRegistered: result['already_registered'] == true,
      pointsAwarded: (result['puntos_otorgados'] as num?)?.toInt() ?? 0,
    );
  }
}
