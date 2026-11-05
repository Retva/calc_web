/// Разбор и форматирование чисел, общие для калькулятора и конвертера.
library;

import 'dart:math' as math;


double? parseNumber(String? raw) {
  if (raw == null) return null;
  final text = raw.trim().replaceAll(',', '.');
  if (text.isEmpty) return null;
  final value = double.tryParse(text);
  if (value == null || !value.isFinite) return null;
  return value;
}


String formatNumber(double value, {int fractionDigits = 6}) {
  if (value.isNaN) return 'NaN';
  if (value.isInfinite) return value > 0 ? '∞' : '-∞';
  if (value == 0) return '0';

  final abs = value.abs();
  // Число меньше половины последнего разряда округлилось бы до нуля.
  final smallest = 0.5 * math.pow(10, -fractionDigits);
  if (abs >= 1e15 || abs < smallest) {
    final parts = value.toStringAsExponential(6).split('e');
    return '${_trimZeros(parts[0])}e${parts[1]}';
  }

  final result = _trimZeros(value.toStringAsFixed(fractionDigits));
  // Отрицательное число, округлившееся до нуля, не должно давать "-0".
  return result == '-0' ? '0' : result;
}

String _trimZeros(String number) {
  if (!number.contains('.')) return number;
  return number
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
