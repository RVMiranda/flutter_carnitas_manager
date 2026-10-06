import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exquisssita_manager/data/sync/retry_policy.dart';
import 'package:exquisssita_manager/data/sync/conflict_resolver.dart';

void main() {
  test('SQLSTATE is classified semantically rather than HTTP prefix', () {
    const classifier = SyncErrorClassifier();
    for (final code in [
      '40001',
      '40P01',
      '55P03',
      '08006',
      'PGRST002',
      '429',
    ]) {
      expect(
        classifier.classify(
          PostgrestException(message: 'sensitive', code: code),
        ),
        SyncErrorKind.transient,
      );
    }
    for (final code in ['23505', '23503', '42501', '22023', 'P0001', '50000']) {
      expect(
        classifier.classify(
          PostgrestException(message: 'sensitive', code: code),
        ),
        SyncErrorKind.permanent,
      );
    }
    expect(
      classifier.classify(const SocketException('secret')),
      SyncErrorKind.transient,
    );
    expect(
      classifier.classify(TimeoutException('secret')),
      SyncErrorKind.transient,
    );
    expect(
      classifier.classify(
        const PostgrestException(message: 'secret', code: 'P0004'),
      ),
      SyncErrorKind.conflict,
    );
    expect(
      classifier.safeCode(SyncErrorKind.permanent),
      isNot(contains('secret')),
    );
  });
  test('equal jitter remains bounded with variation', () {
    final retry = RetryPolicy(random: Random(42));
    final values = List.generate(100, (_) => retry.delay(30).inMilliseconds);
    expect(values.every((v) => v >= 60000 && v <= 120000), isTrue);
    expect(values.toSet().length, greaterThan(1));
  });
  test(
    'dirty employee/payroll and operational data never silently lose edits',
    () {
      const resolver = ConflictResolver();
      for (final entity in [
        'mesas',
        'ordenes',
        'promociones',
        'empleados',
        'historial_pagos_empleados',
      ]) {
        expect(
          resolver.resolve(
            entity: entity,
            dirty: true,
            baseVersion: 1,
            serverVersion: 2,
          ),
          ConflictDecision.review,
        );
      }
      expect(
        resolver.resolve(
          entity: 'mesas',
          dirty: false,
          baseVersion: 1,
          serverVersion: 2,
        ),
        ConflictDecision.applyServer,
      );
    },
  );
}
