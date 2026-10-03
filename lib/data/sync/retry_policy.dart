import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sync_models.dart';

enum SyncErrorKind { transient, permanent, conflict, authentication }

class SyncErrorClassifier {
  const SyncErrorClassifier();
  SyncErrorKind classify(Object error) {
    if (error is SyncConflict) return SyncErrorKind.conflict;
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return SyncErrorKind.transient;
    }
    if (error is AuthException) return SyncErrorKind.authentication;
    if (error is PostgrestException) {
      final code = error.code;
      if (const {
        '40001',
        '40P01',
        '55P03',
        '57014',
        '53300',
        '53400',
        '57P01',
        '57P02',
        '57P03',
        '08000',
        '08001',
        '08003',
        '08004',
        '08006',
        '08007',
        '08P01',
        'PGRST000',
        'PGRST001',
        'PGRST002',
        'PGRST003',
        '408',
        '429',
        '500',
        '502',
        '503',
        '504',
      }.contains(code)) {
        return SyncErrorKind.transient;
      }
      if (code == '401' || code == 'PGRST301' || code == 'PGRST303') {
        return SyncErrorKind.authentication;
      }
      if (code == 'P0004') return SyncErrorKind.conflict;
    }
    // Constraints, permissions, malformed payloads and unknown errors require
    // review. Never interpret an arbitrary SQLSTATE starting with 5 as HTTP.
    return SyncErrorKind.permanent;
  }

  String safeCode(SyncErrorKind kind) => switch (kind) {
    SyncErrorKind.transient => 'temporary_unavailable',
    SyncErrorKind.authentication => 'session_required',
    SyncErrorKind.conflict => 'conflict_requires_review',
    SyncErrorKind.permanent => 'operation_requires_review',
  };
}

class RetryPolicy {
  RetryPolicy({
    Random? random,
    this.maxAttempts = 8,
    this.cap = const Duration(minutes: 2),
  }) : _random = random ?? Random.secure();
  final Random _random;
  final int maxAttempts;
  final Duration cap;
  Duration delay(int attempt) {
    final upper = min(cap.inMilliseconds, 1000 * (1 << attempt.clamp(0, 16)));
    // Equal jitter avoids immediate tight retries and remains bounded.
    return Duration(milliseconds: upper ~/ 2 + _random.nextInt(upper ~/ 2 + 1));
  }
}
