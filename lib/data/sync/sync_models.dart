import '../../core/connectivity/connectivity_service.dart';

class SyncSnapshot {
  const SyncSnapshot(this.status, {this.pending = 0, this.failed = 0});
  final ConnectivityStatus status;
  final int pending;
  final int failed;
}

class RemoteChange {
  const RemoteChange({
    required this.cursor,
    required this.entity,
    required this.id,
    required this.version,
    required this.data,
    this.deleted = false,
  });
  final int cursor;
  final String entity;
  final String id;
  final int version;
  final Map<String, Object?> data;
  final bool deleted;
}

class PullPage {
  const PullPage(this.changes, this.cursor, this.watermark, this.hasMore);
  final List<RemoteChange> changes;
  final int cursor;
  final int watermark;
  final bool hasMore;
}

class SyncConflict implements Exception {
  const SyncConflict();
}

class SyncContractException implements Exception {
  const SyncContractException();
}
