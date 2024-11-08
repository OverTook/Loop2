import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String KEY_KEYBOARD_HEIGHT = 'keyboardHeight';

class TempManager {
  double _keyboardHeight = 0;

  double getKeyboardHeight() => _keyboardHeight;
  void setKeyboardHeight(double value) async {
    _keyboardHeight = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(KEY_KEYBOARD_HEIGHT, value);
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    _keyboardHeight = prefs.getDouble(KEY_KEYBOARD_HEIGHT) ?? 0;
  }

  TempManager._privateConstructor();
  static final TempManager _instance = TempManager._privateConstructor();
  factory TempManager() {
    return _instance;
  }
}