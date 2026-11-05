import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ink_panel.dart';
import '../widgets/page_shell.dart';

/// Общий экран результата для калькулятора и конвертера.
/// Все данные сюда приходят из адресной строки (их разбирает builder
/// маршрута). Экран не знает, откуда пришёл пользователь: из формы,
/// по закладке или по ссылке, набранной вручную в новой вкладке.
/// Передаётся либо [value] (успех), либо [error].
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.title,
    required this.backPath,
    required this.backLabel,
    this.expression,
    this.value,
    this.note,
    this.error,
  }) : assert((value == null) != (error == null),
            'Нужно передать либо value, либо error');

  final String title;
  final String? expression;
  final String? value;
  final String? note;
  final String? error;

  final String backPath;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final error = this.error;
    final isError = error != null;

    return PageShell(
      title: title,
      // Если экран открыт поверх формы, AppBar покажет стрелку «назад».
      showHomeButton: false,
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkPanel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Шапка чека.
                Container(
                  color: isError ? p.danger : p.ink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        isError ? 'ОШИБКА' : 'РЕЗУЛЬТАТ',
                        style: monoCaption(p, color: p.paper),
                      ),
                      const Spacer(),
                      Icon(
                        isError ? Icons.error_outline : Icons.check,
                        size: 18,
                        color: p.paper,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: error != null
                      ? _ErrorBody(message: error)
                      : _SuccessBody(
                          expression: expression,
                          value: value!,
                          note: note,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => context.go(backPath),
            child: Text(backLabel),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/'),
            child: const Text('На главную'),
          ),
        ],
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.expression,
    required this.value,
    required this.note,
  });

  final String? expression;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expression != null)
          Text(
            expression!,
            style: TextStyle(fontFamily: kMonoFont, fontSize: 20, color: p.muted),
          ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SelectableText(
            value,
            style: TextStyle(
              fontFamily: kMonoFont,
              fontWeight: FontWeight.w500,
              fontSize: 52,
              height: 1.1,
              color: p.accent,
            ),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 10),
          Text(note!, style: monoCaption(p)),
        ],
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Не удалось получить результат',
          style: TextStyle(
            fontFamily: kDisplayFont,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.2,
            color: p.ink,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.dangerSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: p.danger, width: 1.5),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: p.danger,
            ),
          ),
        ),
      ],
    );
  }
}
