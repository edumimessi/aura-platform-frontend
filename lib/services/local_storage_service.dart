/// local_storage_service.dart — Armazenamento local com SQLite
///
/// Implementa o padrão offline-first:
/// 1. Salva dados localmente imediatamente.
/// 2. Sincroniza com o backend quando há internet.
///
/// Isso garante que o paciente pode registrar dados mesmo sem conexão.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorageService {
  static Database? _db;

  /// Retorna a instância do banco de dados (cria se necessário)
  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  /// Inicializa o banco de dados SQLite
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'aura.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  /// Cria as tabelas locais
  Future<void> _createTables(Database db, int version) async {
    // Registros de humor
    await db.execute('''
      CREATE TABLE mood_records (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        emotions TEXT,
        notes TEXT,
        record_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_error TEXT
      )
    ''');

    // Registros de medicação
    await db.execute('''
      CREATE TABLE medication_records (
        id TEXT PRIMARY KEY,
        medication_id TEXT NOT NULL,
        status TEXT NOT NULL,
        taken_at TEXT,
        skip_reason TEXT,
        synced INTEGER DEFAULT 0,
        sync_error TEXT
      )
    ''');

    // Registros de crise — CRÍTICO: não pode ser esquecido
    await db.execute('''
      CREATE TABLE crisis_records (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        intensity INTEGER NOT NULL,
        crisis_types TEXT,
        has_suicidal_ideation INTEGER DEFAULT 0,
        coping_used TEXT,
        notes TEXT,
        occurred_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        sync_error TEXT
      )
    ''');
  }

  // ============================================================
  // MOOD RECORDS
  // ============================================================

  Future<void> saveMoodRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert(
      'mood_records',
      record,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMoodRecords({int days = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return db.query(
      'mood_records',
      where: 'record_date >= ?',
      whereArgs: [cutoffDate.toIso8601String().split('T')[0]],
      orderBy: 'record_date DESC',
    );
  }

  // ============================================================
  // CRISIS RECORDS
  // ============================================================

  Future<void> saveCrisisRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert(
      'crisis_records',
      record,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // SINCRONIZAÇÃO
  // ============================================================

  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String table) async {
    final db = await database;
    return db.query(table, where: 'synced = 0');
  }

  Future<void> markAsSynced(String table, String id) async {
    final db = await database;
    await db.update(
      table,
      {'synced': 1, 'sync_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSyncError(String table, String id, String error) async {
    final db = await database;
    await db.update(
      table,
      {'sync_error': error},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
