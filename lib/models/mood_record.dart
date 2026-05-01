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

  /// Cria um MoodRecord a partir de um Map (JSON)
  factory MoodRecord.fromMap(Map<String, dynamic> map) {
    return MoodRecord(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      score: map['score'] as int,
      emotions: map['emotions'] != null
          ? List<String>.from(map['emotions'])
          : null,
      notes: map['notes'] as String?,
      recordDate: DateTime.parse(map['record_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      synced: (map['synced'] as int? ?? 0) == 1,
    );
  }

  /// Converte para Map (para salvar no SQLite)
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

  /// Converte para JSON (para enviar à API)
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'emotions': emotions,
      'notes': notes,
      'record_date': recordDate.toIso8601String().split('T')[0],
    };
  }

  /// Retorna uma descrição textual do humor
  String get moodLabel {
    if (score <= 2) return 'Muito mal';
    if (score <= 4) return 'Mal';
    if (score <= 6) return 'Regular';
    if (score <= 8) return 'Bem';
    return 'Excelente';
  }
}
