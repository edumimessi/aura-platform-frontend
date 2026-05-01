/// sync_service.dart — Sincronização offline-first
///
/// Sincroniza dados pendentes do SQLite local com o backend.
/// Inclui mood_records, medication_records e crisis_records.
///
/// Padrão DRY: _syncTable evita repetição de código.

import 'package:flutter/foundation.dart';
import 'package:aura_app/services/local_storage_service.dart';
import 'package:aura_app/services/api_service.dart';

class SyncService {
  final _localStorage = LocalStorageService();
  final _apiService = ApiService();

  /// Sincroniza todos os dados pendentes
  Future<void> syncPendingData() async {
    try {
      await _syncTable('mood_records', _apiService.createMoodRecord);
      await _syncTable('medication_records', _apiService.createMoodRecord);
      await _syncTable('crisis_records', _apiService.createCrisisRecord);
    } catch (e) {
      debugPrint('Erro geral na sincronização: $e');
    }
  }

  /// Sincroniza uma tabela específica
  ///
  /// Padrão DRY — evita repetição de código para cada tabela.
  Future<void> _syncTable(
    String tableName,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) syncFn,
  ) async {
    final records = await _localStorage.getUnsyncedRecords(tableName);

    for (final record in records) {
      try {
        await syncFn(record);
        await _localStorage.markAsSynced(tableName, record['id'] as String);
        debugPrint('[$tableName] Sincronizado: ${record['id']}');
      } catch (e) {
        await _localStorage.markSyncError(
            tableName, record['id'] as String, e.toString());
        debugPrint(
            '[$tableName] Falha na sincronização: ${record['id']} → $e');
      }
    }
  }
}
