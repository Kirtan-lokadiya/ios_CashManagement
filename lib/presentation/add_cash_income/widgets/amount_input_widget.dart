import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AmountInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const AmountInputWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateAmount);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final text = widget.controller.text.replaceAll(',', '');
    if (text.isEmpty) {
      setState(() {
        _errorText = 'Amount is required';
      });
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      setState(() {
        _errorText = 'Please enter a valid amount';
      });
      return;
    }

    if (amount <= 0) {
      setState(() {
        _errorText = 'Amount must be greater than 0';
      });
      return;
    }

    if (amount > 10000000) {
      setState(() {
        _errorText = 'Amount cannot exceed ₹1,00,00,000';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return value;

    // Remove existing commas
    value = value.replaceAll(',', '');

    // Check if it's a valid number
    if (double.tryParse(value) == null) return value;

    // Add commas for Indian number system
    return value.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppTheme.lightTheme.colorScheme.primary
                  : _errorText != null
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.outline,
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  '₹',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final formatted = _formatCurrency(newValue.text);
                      return TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.w,
                    ),
                  ),
                  onChanged: (value) {
                    widget.onChanged(value);
                    _validateAmount();
                  },
                ),
              ),
            ],
          ),
        ),
        if (_errorText != null) ...[
          SizedBox(height: 1.h),
          Text(
            _errorText!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
        SizedBox(height: 1.h),
        Text(
          'Enter the amount you received',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
