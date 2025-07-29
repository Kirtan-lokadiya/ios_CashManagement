import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DataManagementWidget extends StatelessWidget {
  const DataManagementWidget({Key? key}) : super(key: key);

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'backup',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Create Backup'),
          ],
        ),
        content: Text(
            'This will create a backup of all your transactions and settings. The backup will be saved locally on your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showProgressDialog(context, 'Creating backup...');
            },
            child: Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'file_download',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Export Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export your transaction data in CSV format.'),
            SizedBox(height: 2.h),
            Text(
              'Export Options:',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 1.h),
            CheckboxListTile(
              title: Text('All Transactions'),
              value: true,
              onChanged: null,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Payment Reminders'),
              value: true,
              onChanged: (value) {},
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Recovery Records'),
              value: false,
              onChanged: (value) {},
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showProgressDialog(context, 'Exporting data...');
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'clear_all',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Clear Cache'),
          ],
        ),
        content: Text(
            'This will clear temporary files and cached data to free up storage space. Your transaction data will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showProgressDialog(context, 'Clearing cache...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 4.w),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );

    // Simulate progress
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Operation completed successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dataOptions = [
      {
        "title": "Backup Data",
        "subtitle": "Create backup of all transactions",
        "icon": "backup",
        "action": () => _showBackupDialog(context),
        "color": AppTheme.lightTheme.colorScheme.primary,
      },
      {
        "title": "Export Data",
        "subtitle": "Export transactions to CSV",
        "icon": "file_download",
        "action": () => _showExportDialog(context),
        "color": AppTheme.lightTheme.colorScheme.primary,
      },
      {
        "title": "Clear Cache",
        "subtitle": "Free up storage space (2.3 MB)",
        "icon": "clear_all",
        "action": () => _showClearCacheDialog(context),
        "color": AppTheme.lightTheme.colorScheme.error,
      },
    ];

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
                  iconName: 'storage',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Data Management',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            ...dataOptions.map((option) => Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CustomIconWidget(
                        iconName: option['icon'],
                        color: option['color'],
                        size: 24,
                      ),
                      title: Text(
                        option['title'],
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: option['title'] == 'Clear Cache'
                              ? AppTheme.lightTheme.colorScheme.error
                              : null,
                        ),
                      ),
                      subtitle: Text(option['subtitle']),
                      trailing: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: option['action'],
                    ),
                    option != dataOptions.last
                        ? Divider(height: 2.h)
                        : SizedBox.shrink(),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
