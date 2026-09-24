import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class DatabaseService {
  DatabaseService({this.inMemory = false});

  static const _databaseName = 'sequence_trainer.db';
  static const _databaseVersion = 1;

  final bool inMemory;
  sqflite.Database? _database;

  sqflite.Database get database {
    final db = _database;
    if (db == null) {
      throw StateError('DatabaseService is not initialized.');
    }
    return db;
  }

  Future<void> initialize() async {
    if (_database != null) return;

    if (inMemory || Platform.isWindows || Platform.isLinux) {
      ffi.sqfliteFfiInit();
      sqflite.databaseFactory = ffi.databaseFactoryFfi;
    }

    final String databasePath;
    if (inMemory) {
      databasePath = sqflite.inMemoryDatabasePath;
    } else if (Platform.isWindows || Platform.isLinux) {
      final supportDirectory = await getApplicationSupportDirectory();
      final databaseDirectory = Directory(p.join(supportDirectory.path, 'databases'));
      await databaseDirectory.create(recursive: true);
      databasePath = p.join(databaseDirectory.path, _databaseName);
    } else {
      databasePath = p.join(await sqflite.getDatabasesPath(), _databaseName);
    }

    _database = await sqflite.openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Reserved for future migrations.
      },
    );
  }

  Future<void> _createSchema(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL,
        difficulty TEXT,
        level_id INTEGER,
        total_questions INTEGER NOT NULL,
        status TEXT NOT NULL,
        best_streak INTEGER NOT NULL DEFAULT 0,
        started_at INTEGER NOT NULL,
        completed_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE session_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        sequence_type TEXT NOT NULL,
        sequence_json TEXT NOT NULL,
        correct_answer INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        user_answer INTEGER,
        is_correct INTEGER,
        answered_at INTEGER,
        FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE,
        UNIQUE(session_id, position)
      )
    ''');

    await db.execute('CREATE INDEX idx_sessions_status ON sessions(status)');
    await db.execute(
      'CREATE INDEX idx_sessions_completed_at ON sessions(completed_at)',
    );
    await db.execute(
      'CREATE INDEX idx_session_items_session_id ON session_items(session_id)',
    );
    await db.execute(
      'CREATE INDEX idx_session_items_sequence_type ON session_items(sequence_type)',
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
