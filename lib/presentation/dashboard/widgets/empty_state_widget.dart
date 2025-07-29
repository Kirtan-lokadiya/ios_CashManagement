import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Illustration
          Container(
            width: 40.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 15.w,
                ),
                SizedBox(height: 2.h),
                Container(
                  width: 20.w,
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  width: 15.w,
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Empty State Text
          Text(
            'No Transactions Yet',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          Text(
            'Start tracking your cash flow by adding your first transaction. Tap the + button to get started.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // CTA Button
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add-cash-income'),
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 5.w,
            ),
            label: Text('Add Your First Transaction'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Secondary Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/add-cash-income'),
                icon: CustomIconWidget(
                  iconName: 'add_circle',
                  color: AppTheme.getSuccessColor(true),
                  size: 4.w,
                ),
                label: Text(
                  'Add Income',
                  style: TextStyle(color: AppTheme.getSuccessColor(true)),
                ),
              ),
              Container(
                width: 1,
                height: 4.h,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
              TextButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/record-payment'),
                icon: CustomIconWidget(
                  iconName: 'remove_circle',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 4.w,
                ),
                label: Text(
                  'Record Expense',
                  style:
                      TextStyle(color: AppTheme.lightTheme.colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
