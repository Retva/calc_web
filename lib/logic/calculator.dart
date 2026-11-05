import 'number_format.dart';

/// Допустимые операции в том виде, в каком они передаются в адресе.
const List<String> kOperations = ['+', '-', '*', '/'];

/// Знак операции для показа на экране.
String operationLabel(String op) => switch (op) {
      '*' => '×',
      '/' => '÷',
      '-' => '−',
      _ => op,
    };

/// Результат вычисления: либо значение, либо описание ошибки.
sealed class CalcResult {
  const CalcResult();
}

class CalcSuccess extends CalcResult {
  final double a;
  final String op;
  final double b;
  final double value;

  const CalcSuccess({
    required this.a,
    required this.op,
    required this.b,
    required this.value,
  });

  String get expression =>
      '${formatNumber(a)} ${operationLabel(op)} ${formatNumber(b)}';
}

class CalcFailure extends CalcResult {
  final String message;
  const CalcFailure(this.message);
}

CalcResult calculate(String? rawA, String? rawOp, String? rawB) {
  // Отсутствие обязательных параметров.
  final missing = <String>[
    if (rawA == null || rawA.trim().isEmpty) 'a',
    if (rawOp == null || rawOp.isEmpty) 'op',
    if (rawB == null || rawB.trim().isEmpty) 'b',
  ];
  if (missing.isNotEmpty) {
    final names = missing.map((name) => '«$name»').join(', ');
    return CalcFailure(
      missing.length == 1
          ? 'В адресе не передан обязательный параметр $names'
          : 'В адресе не переданы обязательные параметры $names',
    );
  }

  // Нечисловые значения.
  final a = parseNumber(rawA);
  final b = parseNumber(rawB);
  if (a == null && b == null) {
    return CalcFailure('Параметры «a» и «b» не являются числами: '
        '«$rawA», «$rawB»');
  }
  if (a == null) return CalcFailure('Параметр «a» не является числом: «$rawA»');
  if (b == null) return CalcFailure('Параметр «b» не является числом: «$rawB»');

  // Неизвестная операция.
  final op = rawOp!;
  if (!kOperations.contains(op)) {
    if (op.trim().isEmpty) {
      // Типичная ошибка: «+» в строке запроса означает пробел.
      return const CalcFailure(
        'Неизвестная операция «пробел». Знак «+» в адресе '
        'нужно кодировать как %2B',
      );
    }
    return CalcFailure('Неизвестная операция «$op». '
        'Допустимы: ${kOperations.join(' ')}');
  }

  // Деление на ноль.
  if (op == '/' && b == 0) {
    return const CalcFailure('Деление на ноль невозможно');
  }

  final value = switch (op) {
    '+' => a + b,
    '-' => a - b,
    '*' => a * b,
    _ => a / b,
  };

  // Переполнение: 1e308 * 10 даёт бесконечность.
  if (!value.isFinite) {
    return const CalcFailure('Результат слишком велик для вычисления');
  }

  return CalcSuccess(a: a, op: op, b: b, value: value);
}
