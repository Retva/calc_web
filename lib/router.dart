import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'logic/calculator.dart';
import 'logic/currency.dart';
import 'logic/number_format.dart';
import 'screens/calculator_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/result_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/calculator',
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return CalculatorScreen(
          initialA: q['a'],
          initialOp: q['op'],
          initialB: q['b'],
        );
      },
      routes: [
        // Вложенный маршрут: итоговый адрес — /calculator/result
        GoRoute(
          path: 'result',
          builder: (context, state) =>
              _calculatorResult(state.uri.queryParameters),
        ),
      ],
    ),
    GoRoute(
      path: '/converter',
      builder: (context, state) {
        final q = state.uri.queryParameters;
        return ConverterScreen(
          initialAmount: q['amount'],
          initialFrom: q['from'],
          initialTo: q['to'],
        );
      },
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) =>
              _converterResult(state.uri.queryParameters),
        ),
      ],
    ),
  ],
  // Аналог страницы 404: сюда попадают все неизвестные адреса.
  errorBuilder: (context, state) => const NotFoundScreen(),
);

/// Экран результата калькулятора строится ТОЛЬКО из параметров адреса.
Widget _calculatorResult(Map<String, String> q) {
  final backPath = _pathWith('/calculator', q, const ['a', 'op', 'b']);
  final result = calculate(q['a'], q['op'], q['b']);

  return switch (result) {
    final CalcSuccess success => ResultScreen(
        title: 'Результат вычисления',
        expression: '${success.expression} =',
        value: formatNumber(success.value),
        backPath: backPath,
        backLabel: 'Изменить выражение',
      ),
    CalcFailure(:final message) => ResultScreen(
        title: 'Результат вычисления',
        error: message,
        backPath: backPath,
        backLabel: 'Вернуться к калькулятору',
      ),
  };
}

/// Экран результата конвертера строится ТОЛЬКО из параметров адреса.
Widget _converterResult(Map<String, String> q) {
  final backPath = _pathWith('/converter', q, const ['amount', 'from', 'to']);
  final result = convert(q['amount'], q['from'], q['to']);

  return switch (result) {
    final ConvertSuccess success => ResultScreen(
        title: 'Результат конвертации',
        expression: '${success.expression} =',
        value: success.formattedValue,
        note: success.rateLine,
        backPath: backPath,
        backLabel: 'Изменить сумму или валюты',
      ),
    ConvertFailure(:final message) => ResultScreen(
        title: 'Результат конвертации',
        error: message,
        backPath: backPath,
        backLabel: 'Вернуться к конвертеру',
      ),
  };
}

String _pathWith(String path, Map<String, String> q, List<String> keys) {
  final params = {
    for (final key in keys)
      if (q[key] != null) key: q[key]!,
  };
  return Uri(path: path, queryParameters: params.isEmpty ? null : params)
      .toString();
}
