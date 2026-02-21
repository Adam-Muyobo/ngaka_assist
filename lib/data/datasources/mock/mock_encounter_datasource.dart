// NgakaAssist
// Mock datasource: Encounters.
// Persists transcript + SOAP draft locally (Hive) in mock mode.

import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../../domain/entities/encounter.dart';
import '../../../domain/entities/icd10_suggestion.dart';
import '../../../domain/entities/soap_draft_note.dart';
import 'mock_seed_data.dart';

class MockEncounterDataSource {
  MockEncounterDataSource();

  final _uuid = const Uuid();

  final Map<String, Encounter> _encounters = <String, Encounter>{};
  final Map<String, List<Icd10Suggestion>> _icdByEncounter = <String, List<Icd10Suggestion>>{};

  Box<String> get _cache => Hive.box<String>(HiveBoxes.mockCache);

  Future<AppResult<Encounter>> startEncounter({required String patientId, required String type}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final id = 'e_${_uuid.v4()}';
    final encounter = Encounter(
      id: id,
      patientId: patientId,
      type: type,
      startedAt: DateTime.now(),
      status: 'in_progress',
    );
    _encounters[id] = encounter;

    await _cache.delete(_signedAtKey(id));

    // Seed persisted draft + transcript.
    final draft = MockSeedData.soapDraft(id);
    await _cache.put(_soapKey(id), jsonEncode(draft.toJson()));
    await _cache.put(_transcriptKey(id), draft.transcript);
    final icd = MockSeedData.icd10();
    _icdByEncounter[id] = icd;
    await _cache.put(_icdKey(id), jsonEncode(icd.map((e) => e.toJson()).toList()));
    return AppResult.ok(encounter);
  }

  Future<AppResult<void>> uploadAudio({
    required String encounterId,
    required Uint8List bytes,
    required String filename,
  }) async {
    // Placeholder only (per requirement).
    // TODO(ngakaassist): Integrate real recorder plugin + upload + queue when offline.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _cache.put(_audioRefKey(encounterId), 'mock://audio/$filename (${bytes.length} bytes)');
    return AppResult.ok(null);
  }

  Future<AppResult<String>> getTranscript(String encounterId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final t = _cache.get(_transcriptKey(encounterId)) ?? '';
    return AppResult.ok(t);
  }

  Future<AppResult<void>> saveTranscript(String encounterId, String transcript) async {
    await _cache.put(_transcriptKey(encounterId), transcript);
    return AppResult.ok(null);
  }

  Future<AppResult<SoapDraftNote>> getSoapDraft(String encounterId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final raw = _cache.get(_soapKey(encounterId));
    if (raw == null || raw.isEmpty) {
      final draft = MockSeedData.soapDraft(encounterId);
      return AppResult.ok(draft);
    }
    return AppResult.ok(SoapDraftNote.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>()));
  }

  Future<AppResult<SoapDraftNote>> updateSoapDraft(SoapDraftNote draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final updated = draft.copyWith(updatedAt: DateTime.now());
    await _cache.put(_soapKey(draft.encounterId), jsonEncode(updated.toJson()));
    await _cache.put(_transcriptKey(draft.encounterId), updated.transcript);
    return AppResult.ok(updated);
  }

  Future<AppResult<List<Icd10Suggestion>>> getIcd10Suggestions(String encounterId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final cached = _cache.get(_icdKey(encounterId));
    if (cached != null && cached.isNotEmpty) {
      final list = (jsonDecode(cached) as List)
          .whereType<Map>()
          .map((e) => Icd10Suggestion.fromJson(e.cast<String, dynamic>()))
          .toList();
      _icdByEncounter[encounterId] = list;
      return AppResult.ok(list);
    }
    return AppResult.ok(List<Icd10Suggestion>.from(_icdByEncounter[encounterId] ?? MockSeedData.icd10()));
  }

  Future<AppResult<List<Icd10Suggestion>>> updateIcd10Suggestions(
    String encounterId,
    List<Icd10Suggestion> suggestions,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _icdByEncounter[encounterId] = suggestions;
    await _cache.put(_icdKey(encounterId), jsonEncode(suggestions.map((e) => e.toJson()).toList()));
    return AppResult.ok(suggestions);
  }

  Future<AppResult<void>> signEncounter(String encounterId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final existing = _encounters[encounterId];
    if (existing != null) {
      final signedAt = DateTime.now();
      _encounters[encounterId] = Encounter(
        id: existing.id,
        patientId: existing.patientId,
        type: existing.type,
        startedAt: existing.startedAt,
        signedAt: signedAt,
        status: 'signed',
      );
      await _cache.put(_signedAtKey(encounterId), signedAt.toIso8601String());
    }
    return AppResult.ok(null);
  }

  Encounter? getEncounter(String id) => _encounters[id];

  DateTime? getSignedAt(String encounterId) {
    final raw = _cache.get(_signedAtKey(encounterId));
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  String? getAudioRef(String encounterId) => _cache.get(_audioRefKey(encounterId));

  String _soapKey(String encounterId) => 'soap:$encounterId';
  String _transcriptKey(String encounterId) => 'transcript:$encounterId';
  String _audioRefKey(String encounterId) => 'audio_ref:$encounterId';
  String _icdKey(String encounterId) => 'icd10:$encounterId';
  String _signedAtKey(String encounterId) => 'signed_at:$encounterId';
}
