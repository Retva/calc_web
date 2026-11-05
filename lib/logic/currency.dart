import 'number_format.dart';

/// Валюта и её курс к рублю.
class Currency {
  final String code;
  final String name;

  final double rateToRub;

  const Currency(this.code, this.name, this.rateToRub);
}

const List<Currency> kCurrencies = [
  Currency('RUB', 'Российский рубль', 1),
  Currency('USD', 'Доллар США', 81.67),
  Currency('EUR', 'Евро', 91.6),
  Currency('GBP', 'Фунт стерлингов', 110.1856),
  Currency('CNY', 'Китайский юань', 12.2570),
  Currency('JPY', 'Японская иена', 0.518016),
  Currency('KZT', 'Казахстанский тенге', 0.180598),
];

const String kDefaultFrom = 'USD';
const String kDefaultTo = 'RUB';

/// Поиск валюты по коду без учёта регистра. null — если такой нет.
Currency? currencyByCode(String? code) {
  if (code == null) return null;
  final normalized = code.trim().toUpperCase();
  for (final currency in kCurrencies) {
    if (currency.code == normalized) return currency;
  }
  return null;
}

sealed class ConvertResult {
  const ConvertResult();
}

class ConvertSuccess extends ConvertResult {
  final double amount;
  final Currency from;
  final Currency to;
  final double value;

  const ConvertSuccess({
    required this.amount,
    required this.from,
    required this.to,
    required this.value,
  });

  /// Курс одной единицы исходной валюты в целевой.
  double get rate => from.rateToRub / to.rateToRub;

  String get expression => '${formatMoney(amount)} ${from.code}';
  String get formattedValue => '${formatMoney(value)} ${to.code}';
  String get rateLine =>
      '1 ${from.code} = ${formatNumber(rate, fractionDigits: 6)} ${to.code}';
}

class ConvertFailure extends ConvertResult {
  final String message;
  const ConvertFailure(this.message);
}

/// Денежные суммы: не больше четырёх знаков после запятой,
/// чтобы мелкие суммы (1 KZT → GBP) не превращались в 0.
String formatMoney(double value) => formatNumber(value, fractionDigits: 4);

/// Конвертирует сумму по «сырым» значениям из адресной строки.
ConvertResult convert(String? rawAmount, String? rawFrom, String? rawTo) {
  final missing = <String>[
    if (rawAmount == null || rawAmount.trim().isEmpty) 'amount',
    if (rawFrom == null || rawFrom.trim().isEmpty) 'from',
    if (rawTo == null || rawTo.trim().isEmpty) 'to',
  ];
  if (missing.isNotEmpty) {
    final names = missing.map((name) => '«$name»').join(', ');
    return ConvertFailure(
      missing.length == 1
          ? 'В адресе не передан обязательный параметр $names'
          : 'В адресе не переданы обязательные параметры $names',
    );
  }

  final amount = parseNumber(rawAmount);
  if (amount == null) {
    return ConvertFailure('Сумма не является числом: «$rawAmount»');
  }
  if (amount < 0) {
    return const ConvertFailure('Сумма не может быть отрицательной');
  }

  final from = currencyByCode(rawFrom);
  if (from == null) return ConvertFailure('Неизвестная валюта «$rawFrom»');
  final to = currencyByCode(rawTo);
  if (to == null) return ConvertFailure('Неизвестная валюта «$rawTo»');

  final value = amount * from.rateToRub / to.rateToRub;
  if (!value.isFinite) {
    return const ConvertFailure('Сумма слишком велика для конвертации');
  }

  return ConvertSuccess(amount: amount, from: from, to: to, value: value);
}
