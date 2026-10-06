import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/database_provider.dart';
import 'promotion_repository.dart';

part 'promotion_providers.g.dart';

@Riverpod(keepAlive: true)
PromotionRepository promotionRepository(Ref ref) =>
    LocalPromotionRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<PromocionesTableData>> promotions(Ref ref) =>
    ref.watch(promotionRepositoryProvider).watchAll();
