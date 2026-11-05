import 'package:calc_web/logic/currency.dart';
import 'package:flutter_test/flutter_test.dart';

ConvertSuccess _success(ConvertResult result) {
  expect(result, isA<ConvertSuccess>(),
      reason: result is ConvertFailure ? result.message : null);
  return result as ConvertSuccess;
}

String _error(ConvertResult result) {
  expect(result, isA<ConvertFailure>());
  return (result as ConvertFailure).message;
}

void main() {
  test('валют не меньше пяти, коды уникальны', () {
    expect(kCurrencies.length, greaterThanOrEqualTo(5));
    final codes = kCurrencies.map((c) => c.code).toSet();
    expect(codes.length, kCurrencies.length);
  });

  test('USD → RUB по курсу', () {
    final r = _success(convert('100', 'USD', 'RUB'));
    expect(r.value, closeTo(9250, 1e-9));
    expect(r.formattedValue, '9250 RUB');
  });

  test('RUB → USD и обратно даёт исходную сумму', () {
    final there = _success(convert('1000', 'RUB', 'USD')).value;
    final back = _success(convert('$there', 'USD', 'RUB')).value;
    expect(back, closeTo(1000, 1e-9));
  });

  test('одинаковые валюты — сумма не меняется', () {
    expect(_success(convert('42.5', 'EUR', 'EUR')).value, 42.5);
  });

  test('код валюты без учёта регистра', () {
    expect(_success(convert('1', 'usd', 'rub')).value, 92.5);
  });

  test('ошибки ввода', () {
    expect(_error(convert('abc', 'USD', 'RUB')), contains('не является числом'));
    expect(_error(convert('-5', 'USD', 'RUB')), contains('отрицательной'));
    expect(_error(convert('1', 'XXX', 'RUB')), contains('Неизвестная валюта'));
    expect(_error(convert(null, 'USD', 'RUB')), contains('«amount»'));
    expect(_error(convert('1', 'USD', null)), contains('«to»'));
  });

  test('мелкие суммы не округляются до нуля', () {
    final r = _success(convert('1', 'KZT', 'GBP'));
    expect(r.formattedValue, isNot(startsWith('0 ')));
  });
}
