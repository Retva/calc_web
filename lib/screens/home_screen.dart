import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ink_panel.dart';
import '../widgets/page_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Ширина, начиная с которой карточки встают в ряд.
  static const _wideBreakpoint = 640.0;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    const calculator = _SectionCard(
      number: '01',
      icon: Icons.calculate_outlined,
      title: 'Калькулятор',
      path: '/calculator',
    );
    const converter = _SectionCard(
      number: '02',
      icon: Icons.currency_exchange,
      title: 'Конвертер валют',
      path: '/converter',
      highlighted: true,
    );

    return PageShell(
      title: 'Главная',
      showHomeButton: false,
      maxWidth: 880,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideBreakpoint;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Считаем\nи ',
                  children: [
                    TextSpan(
                      text: 'меняем',
                      style: TextStyle(color: p.accent),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                style: TextStyle(
                  fontFamily: kDisplayFont,
                  fontWeight: FontWeight.w800,
                  fontSize: isWide ? 64 : 40,
                  height: 1.02,
                  color: p.ink,
                ),
              ),
              const SizedBox(height: 36),
              if (isWide)
                const IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: calculator),
                      SizedBox(width: 24),
                      Expanded(child: converter),
                    ],
                  ),
                )
              else ...const [
                calculator,
                SizedBox(height: 20),
                converter,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  const _SectionCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.path,
    this.highlighted = false,
  });

  final String number;
  final IconData icon;
  final String title;
  final String path;
  final bool highlighted;

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fg = widget.highlighted ? p.onHighlight : p.ink;

    return InkPanel(
      padding: EdgeInsets.zero,
      lifted: _hover,
      color: widget.highlighted ? p.highlight : p.surface,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.go(widget.path),
          onHover: (value) => setState(() => _hover = value),
          onFocusChange: (value) => setState(() => _hover = value),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.number,
                      style: TextStyle(
                        fontFamily: kMonoFont,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: widget.highlighted ? fg : p.accent,
                      ),
                    ),
                    const Spacer(),
                    Icon(widget.icon, size: 30, color: fg),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: kDisplayFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    height: 1.15,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
