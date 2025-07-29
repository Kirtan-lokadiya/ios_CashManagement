import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AboutSectionWidget extends StatelessWidget {
  const AboutSectionWidget({Key? key}) : super(key: key);

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CashFlow Manager',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                Text(
                  'Version 1.0.0',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal finance management app for tracking cash transactions and payment reminders.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'Features:',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 1.h),
            _buildFeatureItem('• Cash income tracking'),
            _buildFeatureItem('• Payment reminders'),
            _buildFeatureItem('• Money recovery alerts'),
            _buildFeatureItem('• Transaction history'),
            _buildFeatureItem('• Multi-language support'),
            SizedBox(height: 2.h),
            Text(
              'Developed with ❤️ for personal finance management',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        feature,
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Collection',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              Text(
                'CashFlow Manager stores all data locally on your device. We do not collect, transmit, or store any personal information on external servers.',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                'Data Security',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              Text(
                'Your financial data is encrypted and stored securely on your device. Biometric authentication and PIN protection add additional security layers.',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                'Permissions',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              Text(
                'The app requests minimal permissions: contacts (for recipient selection), notifications (for reminders), and storage (for data backup).',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usage Agreement',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              Text(
                'By using CashFlow Manager, you agree to use the app responsibly for personal finance management purposes only.',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                'Data Responsibility',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              Text(
                'Users are responsible for maintaining backups of their financial data. The app provides backup features, but users should regularly export their data.',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                'Limitation of Liability',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              Text(
                'The app is provided "as is" without warranties. Users should verify all financial calculations and maintain independent records.',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> aboutItems = [
      {
        "title": "App Information",
        "subtitle": "Version 1.0.0 (Build 1)",
        "icon": "info",
        "action": () => _showAppInfo(context),
      },
      {
        "title": "Privacy Policy",
        "subtitle": "How we protect your data",
        "icon": "privacy_tip",
        "action": () => _showPrivacyPolicy(context),
      },
      {
        "title": "Terms of Service",
        "subtitle": "Usage terms and conditions",
        "icon": "description",
        "action": () => _showTermsOfService(context),
      },
      {
        "title": "Rate App",
        "subtitle": "Share your feedback",
        "icon": "star_rate",
        "action": () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thank you for your feedback!')),
          );
        },
      },
      {
        "title": "Contact Support",
        "subtitle": "Get help and support",
        "icon": "support_agent",
        "action": () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Support contact: support@cashflowmanager.com')),
          );
        },
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
                  iconName: 'info_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'About',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            ...aboutItems.map((item) => Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CustomIconWidget(
                        iconName: item['icon'],
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      title: Text(item['title']),
                      subtitle: Text(item['subtitle']),
                      trailing: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: item['action'],
                    ),
                    item != aboutItems.last
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
