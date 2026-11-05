import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Панель с толстой обводкой и жёсткой тенью без размытия —
/// основной строительный блок интерфейса вместо стандартной Card.
///
/// [lifted] — состояние при наведении мыши: панель «приподнимается»,
/// тень удлиняется.
class InkPanel extends StatelessWidget {
  const InkPanel({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(24),
    this.lifted = false,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final bool lifted;

  static const radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final shift = lifted ? -3.0 : 0.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(shift, shift, 0),
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.ink, width: 2),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            offset: lifted ? const Offset(9, 9) : const Offset(6, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Заголовок экрана над формой.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: kDisplayFont,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          height: 1.1,
          color: p.ink,
        ),
      ),
    );
  }
}
