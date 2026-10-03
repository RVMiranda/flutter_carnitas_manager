// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$promotionRepositoryHash() =>
    r'2e6d50651c3afb2a731269564b1d2c78a23bf06d';

/// See also [promotionRepository].
@ProviderFor(promotionRepository)
final promotionRepositoryProvider = Provider<PromotionRepository>.internal(
  promotionRepository,
  name: r'promotionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$promotionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PromotionRepositoryRef = ProviderRef<PromotionRepository>;
String _$promotionsHash() => r'58983fc0b38f83fc38227a01d250b620532ad196';

/// See also [promotions].
@ProviderFor(promotions)
final promotionsProvider =
    AutoDisposeStreamProvider<List<PromocionesTableData>>.internal(
      promotions,
      name: r'promotionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$promotionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PromotionsRef =
    AutoDisposeStreamProviderRef<List<PromocionesTableData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
