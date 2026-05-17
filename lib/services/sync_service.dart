/// sync_service.dart — Sincronização offline-first
///
/// Sincroniza dados pendentes do SQLite local com o backend.
/// Converte o formato local antes de enviar para a API, evitando que
/// metadados do SQLite vazem para os endpoints.

import 'package:flutter/foundation.dart';
import 'package:aura_app/services/local_storage_service.dart';
import 'package:aura_app/services/api_service.dart';

class SyncService {
  final _localStorage = LocalStorageService();
  final _apiService = ApiService();

  /// Sincroniza todos os dados pendentes.
  Future<void> syncPendingData() async {
    await _syncTable(
      'mood_records',
      (record) => _apiService.createMoodRecord(_moodPayload(record)),
    );
    await _syncTable(
      'medication_records',
      (record) => _apiService.createModuleRecord(
        'medications',
        _medicationPayload(record),
      ),
    );
    await _syncTable(
      'crisis_records',
      (record) => _apiService.createCrisisRecord(_crisisPayload(record)),
    );
  }

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
          tableName,
          record['id'] as String,
          e.toString(),
        );
        debugPrint('[$tableName] Falha na sincronização: ${record['id']} -> $e');
      }
    }
  }

  Map<String, dynamic> _moodPayload(Map<String, dynamic> record) {
    return {
      'score': record['score'],
      'emotions': _stringList(record['emotions']),
      'notes': record['notes'],
      'record_date': record['record_date'],
    };
  }

  Map<String, dynamic> _crisisPayload(Map<String, dynamic> record) {
    return {
      'intensity': record['intensity'],
      'crisis_types': _stringList(record['crisis_types']),
      'has_suicidal_ideation': _boolValue(record['has_suicidal_ideation']),
      'coping_used': _stringList(record['coping_used']),
      'notes': record['notes'],
      'occurred_at': record['occurred_at'],
    };
  }

  Map<String, dynamic> _medicationPayload(Map<String, dynamic> record) {
    return {
      'medication_id': record['medication_id'],
      'status': record['status'],
      'taken_at': record['taken_at'],
      'skip_reason': record['skip_reason'],
    };
  }

  List<String> _stringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) return value.map((item) => item.toString()).toList();
    if (value is String) {
      if (value.trim().isEmpty) return <String>[];
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <String>[value.toString()];
  }

  bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}
