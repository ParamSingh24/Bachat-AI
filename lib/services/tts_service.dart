import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSpeechRate(0.5); // Natural speech rate
    await _flutterTts.setPitch(1.0); // Resetting to natural pitch (1.0) for standard Indian voice
  }

  // Set the language based on user's choice
  Future<void> setLanguage(bool isHindi) async {
    if (isHindi) {
      await _flutterTts.setLanguage("hi-IN");
    } else {
      await _flutterTts.setLanguage("en-IN");
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> speak(String text, {bool isHindi = false}) async {
    await stop();
    await setLanguage(isHindi);
    await _flutterTts.speak(text);
  }
}
