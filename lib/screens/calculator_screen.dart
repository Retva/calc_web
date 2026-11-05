import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/calculator.dart';
import '../logic/number_format.dart';
import '../theme/app_theme.dart';
import '../widgets/ink_panel.dart';
import '../widgets/page_shell.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    this.initialA,
    this.initialOp,
    this.initialB,
  });

  final String? initialA;
  final String? initialOp;
  final String? initialB;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bFieldKey = GlobalKey<FormFieldState<String>>();
  late final TextEditingController _aController;
  late final TextEditingController _bController;
  late String _operation;

  @override
  void initState() {
    super.initState();
    _aController = TextEditingController(text: widget.initialA ?? '');
    _bController = TextEditingController(text: widget.initialB ?? '');
    _operation = _validOperation(widget.initialOp);
  }

  @override
  void didUpdateWidget(covariant CalculatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialA != oldWidget.initialA && widget.initialA != null) {
      _aController.text = widget.initialA!;
    }
    if (widget.initialB != oldWidget.initialB && widget.initialB != null) {
      _bController.text = widget.initialB!;
    }
    if (widget.initialOp != oldWidget.initialOp && widget.initialOp != null) {
      _operation = _validOperation(widget.initialOp);
    }
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  static String _validOperation(String? op) =>
      kOperations.contains(op) ? op! : '+';

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите число';
    if (parseNumber(value) == null) return 'Это не число';
    return null;
  }

  String? _divisorValidator(String? value) {
    final error = _numberValidator(value);
    if (error != null) return error;
    if (_operation == '/' && parseNumber(value) == 0) {
      return 'На ноль делить нельзя';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri(
      path: '/calculator/result',
      queryParameters: {
        'a': _aController.text.trim().replaceAll(',', '.'),
        'op': _operation,
        'b': _bController.text.trim().replaceAll(',', '.'),
      },
    );
    context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return PageShell(
      title: 'Калькулятор',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: 'Калькулятор'),
          InkPanel(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ВЫРАЖЕНИЕ', style: monoCaption(p)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aController,
                    autofocus: true,
                    style: monoInput(p),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: inkInputDecoration(
                      context,
                      label: 'Первое число',
                      hint: 'Например, 10 или 2,5',
                    ),
                    validator: _numberValidator,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (final op in kOperations) ...[
                        if (op != kOperations.first) const SizedBox(width: 10),
                        Expanded(
                          child: _OperationKey(
                            op: op,
                            selected: op == _operation,
                            onTap: () => _selectOperation(op),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: _bFieldKey,
                    controller: _bController,
                    style: monoInput(p),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration:
                        inkInputDecoration(context, label: 'Второе число'),
                    validator: _divisorValidator,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Вычислить'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectOperation(String op) {
    setState(() => _operation = op);
    if (_bController.text.isNotEmpty) {
      _bFieldKey.currentState?.validate();
    }
  }
}

const _operationNames = {
  '+': 'Сложение',
  '-': 'Вычитание',
  '*': 'Умножение',
  '/': 'Деление',
};

class _OperationKey extends StatelessWidget {
  const _OperationKey({
    required this.op,
    required this.selected,
    required this.onTap,
  });

  final String op;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: p.ink, width: selected ? 2.5 : 1.5),
    );
    return Tooltip(
      message: _operationNames[op] ?? op,
      child: Semantics(
        button: true,
        selected: selected,
        label: _operationNames[op],
        child: Material(
          color: selected ? p.accent : p.surface,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  operationLabel(op),
                  style: TextStyle(
                    fontFamily: kMonoFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 26,
                    color: selected ? p.onAccent : p.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
