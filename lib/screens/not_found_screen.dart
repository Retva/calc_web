import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/page_shell.dart';

/// Экран для неизвестных адресов — аналог страницы 404 в Spring.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return PageShell(
      title: 'Страница не найдена',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '404',
              style: TextStyle(
                fontFamily: kDisplayFont,
                fontWeight: FontWeight.w800,
                fontSize: 140,
                height: 1,
                color: p.accent,
                shadows: [Shadow(color: p.shadow, offset: const Offset(6, 6))],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Такой страницы нет',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kDisplayFont,
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: p.ink,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('На главную'),
          ),
        ],
      ),
    );
  }
}
