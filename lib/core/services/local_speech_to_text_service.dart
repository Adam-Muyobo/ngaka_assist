// NgakaAssist
// Local speech-to-text adapter.
// Uses device microphone + platform speech recognizer for in-app transcription.

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../result.dart';

enum RecorderState {
  idle,
  recording,
  paused,
  stopped,
}

abstract class LocalSpeechToTextService {
  RecorderState get recorderState;
  String get transcriptDraft;

  Future<AppResult<void>> startRecording();
  Future<AppResult<void>> pauseRecording();
  Future<AppResult<void>> resumeRecording();
  Future<AppResult<void>> stopRecording();
  Future<AppResult<void>> deleteRecording();
  Future<AppResult<String>> transcribeRecording();
}

class DeviceSpeechToTextService implements LocalSpeechToTextService {
  DeviceSpeechToTextService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  RecorderState _state = RecorderState.idle;
  String _draft = '';

  @override
  RecorderState get recorderState => _state;

  @override
  String get transcriptDraft => _draft;

  @override
  Future<AppResult<void>> startRecording() async {
    final initialized = await _speech.initialize();
    if (!initialized) {
      return AppResult.err(AppFailure(message: 'Speech recognition is unavailable on this device'));
    }

    _draft = '';
    final listenRes = await _listen();
    if (!listenRes.isOk) return listenRes;
    _state = RecorderState.recording;
    return AppResult.ok(null);
  }

  @override
  Future<AppResult<void>> pauseRecording() async {
    if (_state != RecorderState.recording) {
      return AppResult.err(AppFailure(message: 'Recording is not active'));
    }

    await _speech.stop();
    _state = RecorderState.paused;
    return AppResult.ok(null);
  }

  @override
  Future<AppResult<void>> resumeRecording() async {
    if (_state != RecorderState.paused) {
      return AppResult.err(AppFailure(message: 'Recording is not paused'));
    }

    final res = await _listen();
    if (!res.isOk) return res;
    _state = RecorderState.recording;
    return AppResult.ok(null);
  }

  @override
  Future<AppResult<void>> stopRecording() async {
    if (_state != RecorderState.recording && _state != RecorderState.paused) {
      return AppResult.err(AppFailure(message: 'No active recording to stop'));
    }

    await _speech.stop();
    _state = RecorderState.stopped;
    return AppResult.ok(null);
  }

  @override
  Future<AppResult<void>> deleteRecording() async {
    await _speech.cancel();
    _draft = '';
    _state = RecorderState.idle;
    return AppResult.ok(null);
  }

  @override
  Future<AppResult<String>> transcribeRecording() async {
    if (_state != RecorderState.stopped && _state != RecorderState.paused) {
      return AppResult.err(AppFailure(message: 'Stop or pause recording before transcribing'));
    }
    final transcript = _draft.trim();
    if (transcript.isEmpty) {
      return AppResult.err(AppFailure(message: 'No speech captured to transcribe'));
    }
    return AppResult.ok(transcript);
  }

  Future<AppResult<void>> _listen() async {
    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        listenMode: ListenMode.dictation,
        partialResults: true,
      );
      return AppResult.ok(null);
    } catch (e) {
      return AppResult.err(AppFailure(message: 'Failed to start microphone: $e'));
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _draft = result.recognizedWords;
  }
}
