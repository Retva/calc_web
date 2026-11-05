import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logic/currency.dart';

/// Настройки, которые должны пережить перезагрузку страницы.
class AppSettings {
  AppSettings._(SharedPreferences prefs)
      : _prefs = prefs,
        themeMode = ValueNotifier(_readThemeMode(prefs));

  static const _themeKey = 'theme_mode';
  static const _fromKey = 'converter_from';
  static const _toKey = 'converter_to';

  static AppSettings? _instance;

  static AppSettings get instance {
    final settings = _instance;
    if (settings == null) {
      throw StateError('AppSettings.init() не был вызван');
    }
    return settings;
  }

  static Future<void> init() async {
    _instance = AppSettings._(await SharedPreferences.getInstance());
  }

  final SharedPreferences _prefs;

  /// Текущая тема. MaterialApp подписан на это значение.
  final ValueNotifier<ThemeMode> themeMode;

  static ThemeMode _readThemeMode(SharedPreferences prefs) {
    return switch (prefs.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setString(_themeKey, mode.name);
  }

  /// Последняя выбранная в конвертере исходная валюта.
  /// Значение из localStorage проверяется: его могли изменить вручную.
  String get lastFrom =>
      currencyByCode(_prefs.getString(_fromKey))?.code ?? kDefaultFrom;

  /// Последняя выбранная в конвертере целевая валюта.
  String get lastTo =>
      currencyByCode(_prefs.getString(_toKey))?.code ?? kDefaultTo;

  Future<void> saveCurrencyPair(String from, String to) async {
    await _prefs.setString(_fromKey, from);
    await _prefs.setString(_toKey, to);
  }
}
