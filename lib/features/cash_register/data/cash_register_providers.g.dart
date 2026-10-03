// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_register_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cashRegisterRepositoryHash() =>
    r'bf1b3bcd2d58f8bc78a8a695d7fa325abee927b8';

/// See also [cashRegisterRepository].
@ProviderFor(cashRegisterRepository)
final cashRegisterRepositoryProvider =
    Provider<CashRegisterRepository>.internal(
      cashRegisterRepository,
      name: r'cashRegisterRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cashRegisterRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashRegisterRepositoryRef = ProviderRef<CashRegisterRepository>;
String _$cashRegisterSummaryHash() =>
    r'0f18c36e0912433bf9f364214d24327793c96612';

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

/// See also [cashRegisterSummary].
@ProviderFor(cashRegisterSummary)
const cashRegisterSummaryProvider = CashRegisterSummaryFamily();

/// See also [cashRegisterSummary].
class CashRegisterSummaryFamily
    extends Family<AsyncValue<CashRegisterSummary>> {
  /// See also [cashRegisterSummary].
  const CashRegisterSummaryFamily();

  /// See also [cashRegisterSummary].
  CashRegisterSummaryProvider call(DateTime date) {
    return CashRegisterSummaryProvider(date);
  }

  @override
  CashRegisterSummaryProvider getProviderOverride(
    covariant CashRegisterSummaryProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cashRegisterSummaryProvider';
}

/// See also [cashRegisterSummary].
class CashRegisterSummaryProvider
    extends AutoDisposeStreamProvider<CashRegisterSummary> {
  /// See also [cashRegisterSummary].
  CashRegisterSummaryProvider(DateTime date)
    : this._internal(
        (ref) => cashRegisterSummary(ref as CashRegisterSummaryRef, date),
        from: cashRegisterSummaryProvider,
        name: r'cashRegisterSummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cashRegisterSummaryHash,
        dependencies: CashRegisterSummaryFamily._dependencies,
        allTransitiveDependencies:
            CashRegisterSummaryFamily._allTransitiveDependencies,
        date: date,
      );

  CashRegisterSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    Stream<CashRegisterSummary> Function(CashRegisterSummaryRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CashRegisterSummaryProvider._internal(
        (ref) => create(ref as CashRegisterSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<CashRegisterSummary> createElement() {
    return _CashRegisterSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CashRegisterSummaryProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CashRegisterSummaryRef
    on AutoDisposeStreamProviderRef<CashRegisterSummary> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _CashRegisterSummaryProviderElement
    extends AutoDisposeStreamProviderElement<CashRegisterSummary>
    with CashRegisterSummaryRef {
  _CashRegisterSummaryProviderElement(super.provider);

  @override
  DateTime get date => (origin as CashRegisterSummaryProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
