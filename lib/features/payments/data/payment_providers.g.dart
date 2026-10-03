// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentPreviewRepositoryHash() =>
    r'5ccc47fa31a81c1b861d7674ab15953622c2305a';

/// See also [paymentPreviewRepository].
@ProviderFor(paymentPreviewRepository)
final paymentPreviewRepositoryProvider =
    Provider<PaymentPreviewRepository>.internal(
      paymentPreviewRepository,
      name: r'paymentPreviewRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paymentPreviewRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentPreviewRepositoryRef = ProviderRef<PaymentPreviewRepository>;
String _$paymentRepositoryHash() => r'b1dce5ea88f56fc7c2b1e39f558dbf0cb6b585dd';

/// See also [paymentRepository].
@ProviderFor(paymentRepository)
final paymentRepositoryProvider = Provider<PaymentRepository>.internal(
  paymentRepository,
  name: r'paymentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentRepositoryRef = ProviderRef<PaymentRepository>;
String _$paymentPreviewHash() => r'a9ba3c833a24b752e700dccc71db29cbf4fd6a1c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [paymentPreview].
@ProviderFor(paymentPreview)
const paymentPreviewProvider = PaymentPreviewFamily();

/// See also [paymentPreview].
class PaymentPreviewFamily extends Family<AsyncValue<PaymentPreview>> {
  /// See also [paymentPreview].
  const PaymentPreviewFamily();

  /// See also [paymentPreview].
  PaymentPreviewProvider call(String orderId) {
    return PaymentPreviewProvider(orderId);
  }

  @override
  PaymentPreviewProvider getProviderOverride(
    covariant PaymentPreviewProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'paymentPreviewProvider';
}

/// See also [paymentPreview].
class PaymentPreviewProvider extends AutoDisposeFutureProvider<PaymentPreview> {
  /// See also [paymentPreview].
  PaymentPreviewProvider(String orderId)
    : this._internal(
        (ref) => paymentPreview(ref as PaymentPreviewRef, orderId),
        from: paymentPreviewProvider,
        name: r'paymentPreviewProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$paymentPreviewHash,
        dependencies: PaymentPreviewFamily._dependencies,
        allTransitiveDependencies:
            PaymentPreviewFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  PaymentPreviewProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    FutureOr<PaymentPreview> Function(PaymentPreviewRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaymentPreviewProvider._internal(
        (ref) => create(ref as PaymentPreviewRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PaymentPreview> createElement() {
    return _PaymentPreviewProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentPreviewProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PaymentPreviewRef on AutoDisposeFutureProviderRef<PaymentPreview> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _PaymentPreviewProviderElement
    extends AutoDisposeFutureProviderElement<PaymentPreview>
    with PaymentPreviewRef {
  _PaymentPreviewProviderElement(super.provider);

  @override
  String get orderId => (origin as PaymentPreviewProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
