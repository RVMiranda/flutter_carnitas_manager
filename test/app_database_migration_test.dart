import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:exquisssita_manager/data/local/database/app_database.dart';

void main() {
  test('migra una base v1 a v6 sin borrar una tabla legado', () async {
    final database = AppDatabase(
      executor: NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute(
            'CREATE TABLE legacy_marker (id TEXT PRIMARY KEY, value TEXT NOT NULL)',
          );
          sqlite.execute(
            "INSERT INTO legacy_marker VALUES ('keep-me', 'preserved')",
          );
          sqlite.execute('PRAGMA user_version = 1');
        },
      ),
    );

    addTearDown(database.close);
    final marker = await database
        .customSelect("SELECT value FROM legacy_marker WHERE id = 'keep-me'")
        .getSingle();

    expect(database.schemaVersion, 6);
    expect(marker.data['value'], 'preserved');
    expect(
      await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'sync_queue'",
          )
          .getSingleOrNull(),
      isNotNull,
    );
  });

  for (final version in [2, 3, 4, 5]) {
    test('migra una base v$version a v6 conservando datos', () async {
      final directory = await Directory.systemTemp.createTemp('drift-upgrade-');
      final path = '${directory.path}${Platform.pathSeparator}database.sqlite';
      final databaseFile = File(path);
      final seeded = AppDatabase(executor: NativeDatabase(databaseFile));
      await seeded.customStatement(
        "INSERT INTO clientes (id, nombre, fecha_registro, created_at, updated_at) "
        "VALUES ('client-1', 'Cliente legado', 1, 1, 1)",
      );
      await seeded.close();

      final raw = sqlite3.sqlite3.open(path);
      if (version == 2) {
        for (final table in [
          'empleados',
          'promociones',
          'venta_diaria',
          'historial_pagos_empleados',
        ]) {
          raw.execute('DROP TABLE $table');
        }
      } else if (version == 3) {
        raw.execute('DROP INDEX IF EXISTS visitas_usuario_fecha');
        raw.execute('ALTER TABLE clientes DROP COLUMN qr_token_hash');
        raw.execute('ALTER TABLE visitas_clientes DROP COLUMN usuario_id');
      }
      raw.execute('PRAGMA user_version = $version');
      raw.dispose();

      final upgraded = AppDatabase(executor: NativeDatabase(databaseFile));
      final client = await (upgraded.select(
        upgraded.clientesTable,
      )..where((table) => table.id.equals('client-1'))).getSingle();
      expect(upgraded.schemaVersion, 6);
      expect(client.nombre, 'Cliente legado');
      expect(
        await upgraded
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'venta_diaria'",
            )
            .getSingleOrNull(),
        isNotNull,
      );
      await upgraded.close();
      await directory.delete(recursive: true);
    });
  }
}
