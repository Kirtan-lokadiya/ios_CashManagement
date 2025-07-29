import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentTransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onDelete;

  const RecentTransactionCardWidget({
    Key? key,
    required this.transaction,
    required this.onDelete,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'hi_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Color _getTransactionColor(String type) {
    return type == 'income'
        ? AppTheme.getSuccessColor(true)
        : AppTheme.lightTheme.colorScheme.error;
  }

  String _getTransactionIcon(String type) {
    return type == 'income' ? 'arrow_downward' : 'arrow_upward';
  }

  @override
  Widget build(BuildContext context) {
    final String type = transaction["type"] as String;
    final double amount = transaction["amount"] as double;
    final String description = transaction["description"] as String;
    final DateTime date = transaction["date"] as DateTime;
    final String category = transaction["category"] as String;
    final String? source = transaction["source"] as String?;
    final String? recipient = transaction["recipient"] as String?;

    return Dismissible(
      key: Key(transaction["id"].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'delete',
              color: Colors.white,
              size: 6.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Delete',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Transaction Icon
            Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _getTransactionColor(type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getTransactionIcon(type),
                  color: _getTransactionColor(type),
                  size: 5.w,
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${type == 'income' ? '+' : '-'}${_formatCurrency(amount)}',
                        style: AppTheme.dataTextStyle(
                          isLight: true,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ).copyWith(
                          color: _getTransactionColor(type),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.lightTheme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          source ?? recipient ?? '',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _formatDate(date),
                        style: AppTheme.lightTheme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
