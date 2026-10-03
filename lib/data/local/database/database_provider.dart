import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'local_persistence.dart';

part 'database_provider.g.dart';

/// Provider global de la base de datos local (Drift).
///
/// Singleton que persiste durante toda la vida de la app.
/// Todos los DAOs y repositorios obtienen acceso a través de este provider.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
LocalPersistence localPersistence(Ref ref) =>
    LocalPersistence(ref.watch(appDatabaseProvider));
