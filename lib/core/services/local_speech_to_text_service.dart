// NgakaAssist
// Local speech-to-text adapter.
// Keeps audio-to-text processing on-device before sending text to backend NLP.

import 'dart:typed_data';

import '../result.dart';

abstract class LocalSpeechToTextService {
  Future<AppResult<String>> transcribe(Uint8List bytes);
}

class PlaceholderLocalSpeechToTextService implements LocalSpeechToTextService {
  @override
  Future<AppResult<String>> transcribe(Uint8List bytes) async {
    if (bytes.isEmpty) {
      return AppResult.err(AppFailure(message: 'No audio captured for transcription'));
    }

    // TODO(ngakaassist): Replace with real on-device STT implementation.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final checksum = bytes.fold<int>(0, (sum, b) => (sum + b) % 1000);
    final transcript = 'Local transcript ($checksum): Patient reports headache for three days and mild fever.';
    return AppResult.ok(transcript);
  }
}
