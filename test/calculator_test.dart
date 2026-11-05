import 'package:calc_web/logic/calculator.dart';
import 'package:calc_web/logic/number_format.dart';
import 'package:flutter_test/flutter_test.dart';

/// Проверка успешного результата с понятным сообщением при провале.
double _value(CalcResult result) {
  expect(result, isA<CalcSuccess>(),
      reason: result is CalcFailure ? result.message : null);
  return (result as CalcSuccess).value;
}

String _error(CalcResult result) {
  expect(result, isA<CalcFailure>());
  return (result as CalcFailure).message;
}

void main() {
  group('calculate: четыре операции', () {
    test('сложение', () => expect(_value(calculate('2', '+', '3')), 5));
    test('вычитание', () => expect(_value(calculate('2', '-', '3')), -1));
    test('умножение', () => expect(_value(calculate('2.5', '*', '4')), 10));
    test('деление', () => expect(_value(calculate('7', '/', '2')), 3.5));

    test('десятичная запятая и пробелы', () {
      expect(_value(calculate(' 2,5 ', '+', '0,5')), 3);
    });

    test('отрицательные числа', () {
      expect(_value(calculate('-4', '*', '-2.5')), 10);
    });

    test('ноль допустим как делимое и как слагаемое', () {
      expect(_value(calculate('0', '/', '5')), 0);
      expect(_value(calculate('5', '+', '0')), 5);
    });
  });

  group('calculate: ошибки', () {
    test('деление на ноль', () {
      expect(_error(calculate('1', '/', '0')), contains('Деление на ноль'));
      expect(_error(calculate('1', '/', '0.0')), contains('Деление на ноль'));
    });

    test('нечисловое значение', () {
      expect(_error(calculate('abc', '+', '1')), contains('«a»'));
      expect(_error(calculate('1', '+', '1x')), contains('«b»'));
      expect(_error(calculate('x', '+', 'y')), contains('не являются числами'));
    });

    test('NaN и бесконечность не считаются числами', () {
      expect(calculate('NaN', '+', '1'), isA<CalcFailure>());
      expect(calculate('Infinity', '+', '1'), isA<CalcFailure>());
      expect(calculate('1e999', '+', '1'), isA<CalcFailure>());
    });

    test('неизвестная операция', () {
      expect(_error(calculate('1', '%', '2')), contains('Неизвестная операция'));
      expect(_error(calculate('1', 'plus', '2')), contains('Неизвестная операция'));
    });

    test('незакодированный «+» превратился в пробел', () {
      expect(_error(calculate('1', ' ', '2')), contains('%2B'));
    });

    test('отсутствие обязательного параметра', () {
      expect(_error(calculate(null, '+', '2')), contains('«a»'));
      expect(_error(calculate('1', null, '2')), contains('«op»'));
      expect(_error(calculate('1', '+', '')), contains('«b»'));
      expect(_error(calculate(null, null, null)), contains('параметры'));
    });

    test('переполнение', () {
      expect(_error(calculate('1e308', '*', '10')), contains('слишком велик'));
    });
  });

  group('formatNumber: округление', () {
    test('10 / 3 не выводится как 3.3333333333333335', () {
      expect(formatNumber(_value(calculate('10', '/', '3'))), '3.333333');
    });

    test('10 / 7 округляется до шести знаков', () {
      expect(formatNumber(_value(calculate('10', '/', '7'))), '1.428571');
    });

    test('очень маленький результат не превращается в 0', () {
      expect(formatNumber(_value(calculate('1', '/', '3000000'))),
          '3.333333e-7');
    });

    test('0.1 + 0.2 = 0.3', () {
      expect(formatNumber(_value(calculate('0.1', '+', '0.2'))), '0.3');
    });

    test('целые без дробной части', () {
      expect(formatNumber(5.0), '5');
      expect(formatNumber(-12.0), '-12');
      expect(formatNumber(0.0), '0');
    });

    test('экспоненциальная запись для крайних значений', () {
      expect(formatNumber(1e20), '1e+20');
      expect(formatNumber(1.5e-12), '1.5e-12');
    });

    test('нет «-0»', () {
      expect(formatNumber(-0.000000000049, fractionDigits: 10), isNot('-0'));
    });
  });

  group('parseNumber', () {
    test('корректный ввод', () {
      expect(parseNumber('42'), 42);
      expect(parseNumber('3,14'), 3.14);
      expect(parseNumber('  -1.5 '), -1.5);
    });

    test('некорректный ввод', () {
      expect(parseNumber(null), isNull);
      expect(parseNumber(''), isNull);
      expect(parseNumber('   '), isNull);
      expect(parseNumber('12abc'), isNull);
      expect(parseNumber('NaN'), isNull);
    });
  });
}
