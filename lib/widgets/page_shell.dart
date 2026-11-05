import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import 'theme_toggle_button.dart';

/// Общий каркас экрана.
///
/// Содержимое центрируется и ограничивается по ширине [maxWidth]:
/// на мониторе 1920 px форма не растягивается на всю ширину,
/// а на телефоне 360 px занимает экран целиком с отступом 16 px.
/// Прокрутка нужна для низких окон и открытой экранной клавиатуры.
class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = 480,
    this.showHomeButton = true,
  });

  final String title;
  final Widget child;
  final double maxWidth;

  /// Кнопка «домой» слева в AppBar. Если false — Flutter сам покажет
  /// стрелку «назад», когда под экраном есть другая страница.
  final bool showHomeButton;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.paper,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: kDisplayFont,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: p.ink,
          ),
        ),
        leading: showHomeButton
            ? IconButton(
                tooltip: 'На главную',
                icon: const Icon(Icons.home_outlined),
                onPressed: () => context.go('/'),
              )
            : null,
        actions: const [ThemeToggleButton(), SizedBox(width: 12)],
        // Линия-«тушь» под шапкой вместо тени.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: p.ink),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Справа и снизу отступ больше: туда падает жёсткая тень панелей.
            padding: const EdgeInsets.fromLTRB(16, 24, 22, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
