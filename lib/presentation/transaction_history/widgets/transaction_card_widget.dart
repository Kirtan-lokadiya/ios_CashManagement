import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final Function(String, Map<String, dynamic>) onAction;

  const TransactionCardWidget({
    Key? key,
    required this.transaction,
    required this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction['type'] == 'income';
    final DateTime date = transaction['date'] as DateTime;
    final double amount = transaction['amount'] as double;

    return Dismissible(
      key: Key(transaction['id']),
      background: _buildSwipeBackground(true),
      secondaryBackground: _buildSwipeBackground(false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onAction('edit', transaction);
        } else {
          onAction('delete', transaction);
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          child: Card(
            elevation: AppTheme.lightTheme.cardTheme.elevation,
            shape: AppTheme.lightTheme.cardTheme.shape,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  _buildTransactionIcon(isIncome),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                transaction['recipient'] ?? 'Unknown',
                                style:
                                    AppTheme.lightTheme.textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₹${amount.toStringAsFixed(0)}',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: isIncome
                                    ? AppTheme.getSuccessColor(true)
                                    : AppTheme.lightTheme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          transaction['source'] ?? '',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                transaction['description'] ?? '',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatDate(date),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionIcon(bool isIncome) {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: isIncome
            ? AppTheme.getSuccessColor(true).withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: isIncome ? 'arrow_downward' : 'arrow_upward',
          color: isIncome
              ? AppTheme.getSuccessColor(true)
              : AppTheme.lightTheme.colorScheme.error,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isEdit) {
    return Container(
      color: isEdit
          ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
          : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
      child: Align(
        alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isEdit ? 'edit' : 'delete',
                color: isEdit
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isEdit ? 'Edit' : 'Delete',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isEdit
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            SizedBox(height: 2.h),
            _buildContextMenuItem(
              context,
              'Edit Transaction',
              'edit',
              () => onAction('edit', transaction),
            ),
            _buildContextMenuItem(
              context,
              'Delete Transaction',
              'delete',
              () => onAction('delete', transaction),
            ),
            _buildContextMenuItem(
              context,
              'Duplicate Transaction',
              'content_copy',
              () => onAction('duplicate', transaction),
            ),
            _buildContextMenuItem(
              context,
              'Set Reminder',
              'notifications',
              () => onAction('reminder', transaction),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
