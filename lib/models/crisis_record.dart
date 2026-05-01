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
      crisisTypes: List<String>.from(map['crisis_types'] ?? []),
      hasSuicidalIdeation: map['has_suicidal_ideation'] as bool? ?? false,
      copingUsed: map['coping_used'] != null
          ? List<String>.from(map['coping_used'])
          : null,
      notes: map['notes'] as String?,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      synced: (map['synced'] as int? ?? 0) == 1,
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
      'coping_used': copingUsed,
      'notes': notes,
    };
  }
}
