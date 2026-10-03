import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:exquisssita_manager/data/local/database/database_provider.dart';
import 'local_payment_preview_repository.dart';
import '../domain/payment_preview.dart';
import '../domain/preview_payment_use_case.dart';

part 'payment_providers.g.dart';

@Riverpod(keepAlive: true)
PaymentPreviewRepository paymentPreviewRepository(Ref ref) =>
    LocalPaymentPreviewRepository(ref.watch(appDatabaseProvider));

@riverpod
Future<PaymentPreview> paymentPreview(Ref ref, String orderId) =>
    PreviewPaymentUseCase(ref.watch(paymentPreviewRepositoryProvider))(orderId);
