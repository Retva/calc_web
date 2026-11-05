import 'package:calc_web/app_settings.dart';
import 'package:calc_web/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.init();
  });

  testWidgets('главная → калькулятор → результат', (tester) async {
    await tester.pumpWidget(const CalcApp());
    await tester.pumpAndSettle();

    expect(find.text('Главная'), findsOneWidget);

    // «Калькулятор» — и заголовок карточки, и подпись кнопки.
    await tester.ensureVisible(find.text('Калькулятор').last);
    await tester.tap(find.text('Калькулятор').last);
    await tester.pumpAndSettle();
    expect(find.text('Первое число'), findsOneWidget);

    // Пустая форма не отправляется.
    await tester.ensureVisible(find.text('Вычислить'));
    await tester.tap(find.text('Вычислить'));
    await tester.pumpAndSettle();
    expect(find.text('Введите число'), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).at(0), '10');
    await tester.enterText(find.byType(TextFormField).at(1), '4');
    await tester.ensureVisible(find.text('Вычислить'));
    await tester.tap(find.text('Вычислить'));
    await tester.pumpAndSettle();

    expect(find.text('Результат вычисления'), findsOneWidget);
    expect(find.text('14'), findsWidgets);
  });

  testWidgets('переключение темы сохраняется', (tester) async {
    await tester.pumpWidget(const CalcApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Тёмная тема'));
    await tester.pumpAndSettle();

    expect(AppSettings.instance.themeMode.value, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });
}
