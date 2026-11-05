import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_settings.dart';
import '../logic/currency.dart';
import '../logic/number_format.dart';
import '../theme/app_theme.dart';
import '../widgets/ink_panel.dart';
import '../widgets/page_shell.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({
    super.key,
    this.initialAmount,
    this.initialFrom,
    this.initialTo,
  });

  final String? initialAmount;
  final String? initialFrom;
  final String? initialTo;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late String _from;
  late String _to;

  int _pairVersion = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
    _applyPairFromWidget();
  }

  @override
  void didUpdateWidget(covariant ConverterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAmount != oldWidget.initialAmount &&
        widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!;
    }
    if (widget.initialFrom != oldWidget.initialFrom ||
        widget.initialTo != oldWidget.initialTo) {
      _applyPairFromWidget();
      _pairVersion++;
    }
  }

  void _applyPairFromWidget() {
    final settings = AppSettings.instance;
    _from = currencyByCode(widget.initialFrom)?.code ?? settings.lastFrom;
    _to = currencyByCode(widget.initialTo)?.code ?? settings.lastTo;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _savePair() {
    AppSettings.instance.saveCurrencyPair(_from, _to);
  }

  void _swap() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
      _pairVersion++;
    });
    _savePair();
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите сумму';
    final amount = parseNumber(value);
    if (amount == null) return 'Это не число';
    if (amount < 0) return 'Сумма не может быть отрицательной';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _savePair();

    final uri = Uri(
      path: '/converter/result',
      queryParameters: {
        'amount': _amountController.text.trim().replaceAll(',', '.'),
        'from': _from,
        'to': _to,
      },
    );
    context.go(uri.toString());
  }

  List<DropdownMenuItem<String>> _items(AppPalette p) => [
        for (final c in kCurrencies)
          DropdownMenuItem(
            value: c.code,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: c.code,
                    style: TextStyle(
                      fontFamily: kMonoFont,
                      fontWeight: FontWeight.w500,
                      color: p.ink,
                    ),
                  ),
                  TextSpan(
                    text: '  ${c.name}',
                    style: TextStyle(color: p.muted),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ];

  Widget _currencyField({
    required AppPalette p,
    required String keyName,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$keyName-$_pairVersion'),
      initialValue: value,
      isExpanded: true,
      dropdownColor: p.surface,
      borderRadius: BorderRadius.circular(12),
      iconEnabledColor: p.ink,
      decoration: inkInputDecoration(context, label: label),
      items: _items(p),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
        _savePair();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return PageShell(
      title: 'Конвертер валют',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Конвертер валют'),
          InkPanel(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ОБМЕН', style: monoCaption(p)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    autofocus: true,
                    style: monoInput(p),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: inkInputDecoration(
                      context,
                      label: 'Сумма',
                      hint: 'Например, 100',
                    ),
                    validator: _amountValidator,
                  ),
                  const SizedBox(height: 16),
                  _currencyField(
                    p: p,
                    keyName: 'from',
                    label: 'Из валюты',
                    value: _from,
                    onChanged: (v) => setState(() => _from = v),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: IconButton(
                      tooltip: 'Поменять валюты местами',
                      onPressed: _swap,
                      style: IconButton.styleFrom(
                        backgroundColor: p.highlight,
                        foregroundColor: p.onHighlight,
                        side: BorderSide(color: p.ink, width: 2),
                      ),
                      icon: const Icon(Icons.swap_vert),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _currencyField(
                    p: p,
                    keyName: 'to',
                    label: 'В валюту',
                    value: _to,
                    onChanged: (v) => setState(() => _to = v),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Конвертировать'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
