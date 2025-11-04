import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final stt.SpeechToText _speech = stt.SpeechToText();

  static Future<bool> init() async {
    return await _speech.initialize();
  }

  static Future<void> startListening(Function(String) onResult) async {
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }
}
