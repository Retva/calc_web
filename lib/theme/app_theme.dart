import 'package:flutter/material.dart';

/// Шрифты лежат в assets/fonts и подключены в pubspec.yaml.
const String kDisplayFont = 'Unbounded'; // заголовки
const String kBodyFont = 'Manrope'; // основной текст
const String kMonoFont = 'JetBrainsMono'; // числа, адреса, подписи

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.highlight,
    required this.onHighlight,
    required this.danger,
    required this.dangerSurface,
    required this.shadow,
  });

  /// Фон страницы.
  final Color paper;

  /// Фон панелей и полей.
  final Color surface;

  /// Основной текст и обводки.
  final Color ink;

  /// Второстепенный текст.
  final Color muted;

  /// Акцент: главная кнопка, выбранная операция, фокус.
  final Color accent;
  final Color onAccent;

  /// Второй цвет: карточка конвертера.
  final Color highlight;
  final Color onHighlight;

  final Color danger;
  final Color dangerSurface;

  /// Цвет жёсткой тени под панелями.
  final Color shadow;

  static const light = AppPalette(
    paper: Color(0xFFF3EEE3),
    surface: Color(0xFFFBF8F2),
    ink: Color(0xFF1B1A17),
    muted: Color(0xFF6E675B),
    accent: Color(0xFFD9481E),
    onAccent: Color(0xFFFFF7EE),
    highlight: Color(0xFFF2C14E),
    onHighlight: Color(0xFF1B1A17),
    danger: Color(0xFF9F1D35),
    dangerSurface: Color(0xFFF6D9DD),
    shadow: Color(0xFF1B1A17),
  );

  static const dark = AppPalette(
    paper: Color(0xFF141619),
    surface: Color(0xFF1D2024),
    ink: Color(0xFFEFE8D8),
    muted: Color(0xFFA39C8E),
    accent: Color(0xFFFF6B3D),
    onAccent: Color(0xFF141619),
    highlight: Color(0xFFE0B04A),
    onHighlight: Color(0xFF141619),
    danger: Color(0xFFFF8A9B),
    dangerSurface: Color(0xFF3A1F25),
    shadow: Color(0xFF7A2E17),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  @override
  AppPalette copyWith({
    Color? paper,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? accent,
    Color? onAccent,
    Color? highlight,
    Color? onHighlight,
    Color? danger,
    Color? dangerSurface,
    Color? shadow,
  }) {
    return AppPalette(
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      highlight: highlight ?? this.highlight,
      onHighlight: onHighlight ?? this.onHighlight,
      danger: danger ?? this.danger,
      dangerSurface: dangerSurface ?? this.dangerSurface,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      paper: mix(paper, other.paper),
      surface: mix(surface, other.surface),
      ink: mix(ink, other.ink),
      muted: mix(muted, other.muted),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      highlight: mix(highlight, other.highlight),
      onHighlight: mix(onHighlight, other.onHighlight),
      danger: mix(danger, other.danger),
      dangerSurface: mix(dangerSurface, other.dangerSurface),
      shadow: mix(shadow, other.shadow),
    );
  }
}

ThemeData buildAppTheme(Brightness brightness) {
  final p =
      brightness == Brightness.light ? AppPalette.light : AppPalette.dark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.accent,
    onPrimary: p.onAccent,
    secondary: p.highlight,
    onSecondary: p.onHighlight,
    error: p.danger,
    onError: p.onAccent,
    surface: p.surface,
    onSurface: p.ink,
    onSurfaceVariant: p.muted,
    outline: p.ink,
    outlineVariant: p.muted,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.paper,
    fontFamily: kBodyFont,
    extensions: [p],
  );

  TextStyle? display(TextStyle? s, FontWeight w) =>
      s?.copyWith(fontFamily: kDisplayFont, fontWeight: w, color: p.ink);

  final t = base.textTheme;
  final textTheme = t.copyWith(
    displayLarge: display(t.displayLarge, FontWeight.w800),
    displayMedium: display(t.displayMedium, FontWeight.w800),
    displaySmall: display(t.displaySmall, FontWeight.w800),
    headlineLarge: display(t.headlineLarge, FontWeight.w600),
    headlineMedium: display(t.headlineMedium, FontWeight.w600),
    headlineSmall: display(t.headlineSmall, FontWeight.w600),
    titleLarge: display(t.titleLarge, FontWeight.w600),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: BorderSide(color: p.ink, width: 2),
  );
  const buttonText = TextStyle(
    fontFamily: kBodyFont,
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  return base.copyWith(
    textTheme: textTheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        minimumSize: const Size.fromHeight(54),
        shape: buttonShape,
        textStyle: buttonText,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        minimumSize: const Size.fromHeight(54),
        shape: buttonShape,
        side: BorderSide(color: p.ink, width: 2),
        textStyle: buttonText,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.accent,
      selectionColor: p.highlight,
      selectionHandleColor: p.accent,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.ink,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: TextStyle(
        color: p.paper,
        fontFamily: kMonoFont,
        fontSize: 12,
      ),
    ),
    dividerColor: p.ink,
  );
}

/// Мелкая моноширинная подпись в верхнем регистре: «ВЫРАЖЕНИЕ», «/calculator».
TextStyle monoCaption(AppPalette p, {Color? color}) => TextStyle(
      fontFamily: kMonoFont,
      fontSize: 12,
      letterSpacing: 1.6,
      color: color ?? p.muted,
    );

/// Оформление поля ввода в общем стиле: светлая подложка,
/// чёрная обводка, при фокусе — терракотовая.
InputDecoration inkInputDecoration(
  BuildContext context, {
  required String label,
  String? hint,
}) {
  final p = AppPalette.of(context);
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: p.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    labelStyle: TextStyle(color: p.muted, fontWeight: FontWeight.w600),
    floatingLabelStyle: TextStyle(color: p.ink, fontWeight: FontWeight.w700),
    hintStyle: TextStyle(color: p.muted),
    errorStyle: TextStyle(color: p.danger, fontWeight: FontWeight.w600),
    border: border(p.ink, 1.5),
    enabledBorder: border(p.ink, 1.5),
    focusedBorder: border(p.accent, 2.5),
    errorBorder: border(p.danger, 1.5),
    focusedErrorBorder: border(p.danger, 2.5),
  );
}

/// Стиль вводимых чисел.
TextStyle monoInput(AppPalette p) => TextStyle(
      fontFamily: kMonoFont,
      fontSize: 18,
      color: p.ink,
    );
