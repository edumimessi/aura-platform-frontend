import 'package:flutter_test/flutter_test.dart';
import 'package:aura_app/models/crisis_record.dart';
import 'package:aura_app/models/mood_record.dart';

void main() {
  test('MoodRecord parses comma separated local emotions', () {
    final record = MoodRecord.fromMap({
      'id': 'mood-1',
      'patient_id': 'patient-1',
      'score': 7,
      'emotions': 'Calmo, Esperançoso',
      'notes': 'Dia melhor',
      'record_date': '2026-05-17',
      'created_at': '2026-05-17T12:00:00.000',
      'synced': 0,
    });

    expect(record.emotions, ['Calmo', 'Esperançoso']);
    expect(record.synced, isFalse);
    expect(record.toJson()['emotions'], ['Calmo', 'Esperançoso']);
  });

  test('CrisisRecord parses SQLite booleans and lists safely', () {
    final record = CrisisRecord.fromMap({
      'id': 'crisis-1',
      'patient_id': 'patient-1',
      'intensity': 8,
      'crisis_types': 'Ansiedade intensa, Ideação suicida',
      'has_suicidal_ideation': 1,
      'coping_used': 'Respiração, Ligou para alguém',
      'notes': null,
      'occurred_at': '2026-05-17T13:00:00.000',
      'synced': 0,
    });

    expect(record.crisisTypes, ['Ansiedade intensa', 'Ideação suicida']);
    expect(record.hasSuicidalIdeation, isTrue);
    expect(record.copingUsed, ['Respiração', 'Ligou para alguém']);
    expect(record.toJson()['occurred_at'], '2026-05-17T13:00:00.000');
  });
}
