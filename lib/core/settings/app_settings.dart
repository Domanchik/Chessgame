import 'package:flutter/material.dart';

class BoardThemeOption {
  final String id;
  final String label;
  final Color light;
  final Color dark;

  const BoardThemeOption({
    required this.id,
    required this.label,
    required this.light,
    required this.dark,
  });
}

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._();
  factory AppSettings() => _instance;
  AppSettings._();

  // ─── Доска ──────────────────────────────────────────────────────────────────

  static const List<BoardThemeOption> boardThemes = [
    BoardThemeOption(
      id: 'classic',
      label: 'Классика',
      light: Color(0xFFE0D6CE),
      dark: Color(0xFF5B3E34),
    ),
    BoardThemeOption(
      id: 'green',
      label: 'Зелёная',
      light: Color(0xFFEEEED2),
      dark: Color(0xFF769656),
    ),
    BoardThemeOption(
      id: 'blue',
      label: 'Синяя',
      light: Color(0xFFDEE3E6),
      dark: Color(0xFF4682B4),
    ),
    BoardThemeOption(
      id: 'purple',
      label: 'Фиолет',
      light: Color(0xFFE8D5F5),
      dark: Color(0xFF7B5EA7),
    ),
    BoardThemeOption(
      id: 'midnight',
      label: 'Ночная',
      light: Color(0xFFB0BEC5),
      dark: Color(0xFF263238),
    ),
  ];

  String _boardThemeId = 'classic';
  String get boardThemeId => _boardThemeId;

  BoardThemeOption get boardTheme =>
      boardThemes.firstWhere((t) => t.id == _boardThemeId);

  void setBoardTheme(String id) {
    _boardThemeId = id;
    notifyListeners();
  }

  // ─── Язык ───────────────────────────────────────────────────────────────────

  String _language = 'ru'; // 'ru' | 'en' | 'ky'
  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  // ─── Звук ───────────────────────────────────────────────────────────────────

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  // ─── Подсветка ходов ────────────────────────────────────────────────────────

  bool _showHints = true;
  bool get showHints => _showHints;

  void toggleHints() {
    _showHints = !_showHints;
    notifyListeners();
  }
}