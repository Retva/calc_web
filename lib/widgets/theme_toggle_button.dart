import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../theme/app_theme.dart';

/// Переключатель светлой и тёмной темы. Выбор сохраняется в localStorage.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Светлая тема' : 'Тёмная тема',
      style: IconButton.styleFrom(
        foregroundColor: p.ink,
        side: BorderSide(color: p.ink, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => AppSettings.instance
          .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
    );
  }
}
