import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isHindi = false;
  bool _isDemoMode = false;
  String _geminiApiKey = '';

  bool get isHindi => _isHindi;
  bool get isDemoMode => _isDemoMode;
  String get geminiApiKey => _geminiApiKey;

  SettingsProvider() {
    _loadPrefs();
  }

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isHindi = prefs.getBool('isHindi') ?? false;
    _isDemoMode = prefs.getBool('isDemoMode') ?? false;
    _geminiApiKey = prefs.getString('geminiApiKey') ?? 'AIzaSyATLuIf2xRybw_C5sd0PNjt9hPnd05OcJw';
    notifyListeners();
  }

  void toggleLanguage() async {
    _isHindi = !_isHindi;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_hindi', _isHindi);
    notifyListeners();
  }

  void toggleDemoMode() async {
    _isDemoMode = !_isDemoMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_demo_mode', _isDemoMode);
    notifyListeners();
  }

  void setGeminiApiKey(String key) async {
    _geminiApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    notifyListeners();
  }
}
