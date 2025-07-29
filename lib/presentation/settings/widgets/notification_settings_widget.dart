import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationSettingsWidget extends StatefulWidget {
  final bool paymentReminders;
  final bool recoveryAlerts;
  final bool dailyBalanceSummary;
  final Function(String, bool) onToggleChanged;

  const NotificationSettingsWidget({
    Key? key,
    required this.paymentReminders,
    required this.recoveryAlerts,
    required this.dailyBalanceSummary,
    required this.onToggleChanged,
  }) : super(key: key);

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  TimeOfDay _reminderTime = TimeOfDay(hour: 21, minute: 0);

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              hourMinuteTextColor: AppTheme.lightTheme.colorScheme.onSurface,
              dialHandColor: AppTheme.lightTheme.colorScheme.primary,
              dialBackgroundColor:
                  AppTheme.lightTheme.colorScheme.primaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Notification Settings',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildNotificationToggle(
              'Payment Reminders',
              'Get notified about upcoming payments',
              'payment',
              widget.paymentReminders,
              'paymentReminders',
            ),
            Divider(height: 3.h),
            _buildNotificationToggle(
              'Recovery Alerts',
              'Alerts for pending money recovery',
              'notification_important',
              widget.recoveryAlerts,
              'recoveryAlerts',
            ),
            Divider(height: 3.h),
            _buildNotificationToggle(
              'Daily Balance Summary',
              'Daily cash flow summary',
              'schedule',
              widget.dailyBalanceSummary,
              'dailyBalanceSummary',
            ),
            widget.dailyBalanceSummary
                ? Column(
                    children: [
                      SizedBox(height: 2.h),
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 8.w),
                        title: Text(
                          'Notification Time',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          _reminderTime.format(context),
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: _showTimePicker,
                          child: Text('Change'),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    String iconName,
    bool value,
    String key,
  ) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: value
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) => widget.onToggleChanged(key, newValue),
        ),
      ],
    );
  }
}
