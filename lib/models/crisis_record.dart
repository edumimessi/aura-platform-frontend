/// crisis_record.dart — Modelo de registro de crise
///
/// Representa um episódio de crise registrado pelo paciente.
/// Gera alerta imediato ao médico.

class CrisisRecord {
  final String id;
  final String patientId;
  final int intensity;
  final List<String> crisisTypes;
  final bool hasSuicidalIdeation;
  final List<String>? copingUsed;
  final String? notes;
  final DateTime occurredAt;
  final bool synced;

  CrisisRecord({
    required this.id,
    required this.patientId,
    required this.intensity,
    required this.crisisTypes,
    this.hasSuicidalIdeation = false,
    this.copingUsed,
    this.notes,
    required this.occurredAt,
    this.synced = false,
  });

  factory CrisisRecord.fromMap(Map<String, dynamic> map) {
    return CrisisRecord(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      intensity: map['intensity'] as int,
      crisisTypes: _stringList(map['crisis_types']),
      hasSuicidalIdeation: _boolValue(map['has_suicidal_ideation']),
      copingUsed: _stringListOrNull(map['coping_used']),
      notes: map['notes'] as String?,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      synced: _boolValue(map['synced']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'intensity': intensity,
      'crisis_types': crisisTypes.join(','),
      'has_suicidal_ideation': hasSuicidalIdeation ? 1 : 0,
      'coping_used': copingUsed?.join(','),
      'notes': notes,
      'occurred_at': occurredAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'intensity': intensity,
      'crisis_types': crisisTypes,
      'has_suicidal_ideation': hasSuicidalIdeation,
      'coping_used': copingUsed ?? <String>[],
      'notes': notes,
      'occurred_at': occurredAt.toIso8601String(),
    };
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
