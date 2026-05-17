/// mood_record.dart — Modelo de registro de humor
///
/// Representa um registro diário de humor do paciente.

class MoodRecord {
  final String id;
  final String patientId;
  final int score;
  final List<String>? emotions;
  final String? notes;
  final DateTime recordDate;
  final DateTime createdAt;
  final bool synced;

  MoodRecord({
    required this.id,
    required this.patientId,
    required this.score,
    this.emotions,
    this.notes,
    required this.recordDate,
    required this.createdAt,
    this.synced = false,
  });

  /// Cria um MoodRecord a partir de um Map (JSON ou SQLite).
  factory MoodRecord.fromMap(Map<String, dynamic> map) {
    return MoodRecord(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      score: map['score'] as int,
      emotions: _stringListOrNull(map['emotions']),
      notes: map['notes'] as String?,
      recordDate: DateTime.parse(map['record_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      synced: _boolValue(map['synced']),
    );
  }

  /// Converte para Map (para salvar no SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'score': score,
      'emotions': emotions?.join(','),
      'notes': notes,
      'record_date': recordDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  /// Converte para JSON (para enviar à API).
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'emotions': emotions ?? <String>[],
      'notes': notes,
      'record_date': recordDate.toIso8601String().split('T')[0],
    };
  }

  /// Retorna uma descrição textual do humor.
  String get moodLabel {
    if (score <= 2) return 'Muito mal';
    if (score <= 4) return 'Mal';
    if (score <= 6) return 'Regular';
    if (score <= 8) return 'Bem';
    return 'Excelente';
  }

  static List<String>? _stringListOrNull(dynamic value) {
    final values = _stringList(value);
    return values.isEmpty ? null : values;
  }

  static List<String> _stringList(dynamic value) {
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

  static bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}
