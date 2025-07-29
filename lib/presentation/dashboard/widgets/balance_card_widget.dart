import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BalanceCardWidget extends StatelessWidget {
  final double balance;
  final bool isVisible;
  final DateTime lastUpdated;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const BalanceCardWidget({
    Key? key,
    required this.balance,
    required this.isVisible,
    required this.lastUpdated,
    required this.isRefreshing,
    required this.onRefresh,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'hi_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Balance',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              GestureDetector(
                onTap: isRefreshing ? null : onRefresh,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isRefreshing
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'refresh',
                          color: Colors.white,
                          size: 5.w,
                        ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Balance Amount
          Row(
            children: [
              Expanded(
                child: isVisible
                    ? Text(
                        _formatCurrency(balance),
                        style: AppTheme.dataTextStyle(
                          isLight: true,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                        ).copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      )
                    : Row(
                        children: List.generate(
                          8,
                          (index) => Container(
                            width: 3.w,
                            height: 3.w,
                            margin: EdgeInsets.only(right: 1.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomIconWidget(
                  iconName: isVisible ? 'visibility' : 'visibility_off',
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Last Updated
          Row(
            children: [
              CustomIconWidget(
                iconName: 'access_time',
                color: Colors.white.withValues(alpha: 0.7),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Updated ${_formatLastUpdated(lastUpdated)}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Balance Status Indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: balance >= 0
                  ? AppTheme.getSuccessColor(true).withValues(alpha: 0.2)
                  : AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: balance >= 0 ? 'trending_up' : 'trending_down',
                  color: balance >= 0
                      ? AppTheme.getSuccessColor(true)
                      : AppTheme.lightTheme.colorScheme.error,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  balance >= 0 ? 'Positive Balance' : 'Negative Balance',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: balance >= 0
                        ? AppTheme.getSuccessColor(true)
                        : AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
