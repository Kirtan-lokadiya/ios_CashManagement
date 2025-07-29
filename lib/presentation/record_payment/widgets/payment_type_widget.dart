import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/suggestion_model.dart';

class PaymentTypeWidget extends StatefulWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const PaymentTypeWidget({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  State<PaymentTypeWidget> createState() => _PaymentTypeWidgetState();
}

class _PaymentTypeWidgetState extends State<PaymentTypeWidget> {
  List<String> _paymentTypes = [];
  final TextEditingController _customTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPaymentTypes();
  }

  void _loadPaymentTypes() {
    final box = Hive.box<Suggestion>('suggestions');
    setState(() {
      _paymentTypes = box.values
        .where((s) => s.type == 'paymentType')
        .map((s) => s.value)
        .toList();
      if (_paymentTypes.isEmpty) {
        final defaults = ['Loan', 'EMI', 'Business', 'Personal', 'Other'];
        for (final val in defaults) {
          box.add(Suggestion(value: val, type: 'paymentType'));
        }
        _paymentTypes = defaults;
      }
    });
  }

  void _showCustomTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Payment Type', style: AppTheme.lightTheme.textTheme.titleLarge),
        content: TextFormField(
          controller: _customTypeController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter payment type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _customTypeController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final customType = _customTypeController.text.trim();
              if (customType.isNotEmpty) {
                final box = Hive.box<Suggestion>('suggestions');
                if (!_paymentTypes.contains(customType)) {
                  await box.add(Suggestion(value: customType, type: 'paymentType'));
                  setState(() {
                    _paymentTypes.add(customType);
                  });
                }
                widget.onTypeChanged(customType);
                _customTypeController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Loan':
        return Icons.account_balance;
      case 'EMI':
        return Icons.credit_card;
      case 'Business':
        return Icons.business;
      case 'Personal':
        return Icons.person;
      case 'Other':
        return Icons.more_horiz;
      default:
        return Icons.payment;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Loan':
        return Colors.orange;
      case 'EMI':
        return Colors.blue;
      case 'Business':
        return Colors.green;
      case 'Personal':
        return Colors.purple;
      case 'Other':
        return Colors.grey;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Type',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              ..._paymentTypes.map((type) {
                final isSelected = type == widget.selectedType;
                final typeColor = _getColorForType(type);
                return GestureDetector(
                  onTap: () => widget.onTypeChanged(type),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSelected ? typeColor.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? typeColor : AppTheme.lightTheme.colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: _getIconForType(type).codePoint.toString(),
                          color: isSelected ? typeColor : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          type,
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? typeColor : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: _showCustomTypeDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Custom',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'info_outline',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Payment type affects reminder options and categorization',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
