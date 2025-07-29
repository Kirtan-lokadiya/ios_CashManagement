import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/language_picker_widget.dart';
import './widgets/firm_management_widget.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLanguage = 'English';
  bool _paymentReminders = true;
  bool _recoveryAlerts = true;
  bool _dailyBalanceSummary = false;
  String _selectedTheme = 'System';
  bool _biometricEnabled = false;
  double _textSize = 16.0;
  bool _reducedMotion = false;

  final List<Map<String, dynamic>> _settingsData = [
    {
      "section": "Firm Management",
      "items": [
        {
          "title": "Manage Firms",
          "subtitle": "Create, edit, and manage your business firms",
          "icon": "business",
          "type": "firm_management"
        }
      ]
    },
    {
      "section": "Language & Region",
      "items": [
        {
          "title": "Language",
          "subtitle": "English",
          "icon": "language",
          "type": "language"
        },
        {
          "title": "Currency Format",
          "subtitle": "Indian Rupee (₹)",
          "icon": "currency_rupee",
          "type": "currency"
        },
        {
          "title": "Date Format",
          "subtitle": "DD/MM/YYYY",
          "icon": "date_range",
          "type": "date"
        }
      ]
    },
    {
      "section": "Notifications",
      "items": [
        {
          "title": "Payment Reminders",
          "subtitle": "Get notified about upcoming payments",
          "icon": "notifications",
          "type": "toggle",
          "value": true
        },
        {
          "title": "Recovery Alerts",
          "subtitle": "Alerts for pending money recovery",
          "icon": "notification_important",
          "type": "toggle",
          "value": true
        },
        {
          "title": "Daily Balance Summary",
          "subtitle": "Daily cash flow summary at 9:00 PM",
          "icon": "schedule",
          "type": "toggle",
          "value": false
        }
      ]
    },
    {
      "section": "Data Management",
      "items": [
        {
          "title": "Backup Data",
          "subtitle": "Create backup of all transactions",
          "icon": "backup",
          "type": "action"
        },
        {
          "title": "Export Data",
          "subtitle": "Export transactions to CSV",
          "icon": "file_download",
          "type": "action"
        },
        {
          "title": "Clear Cache",
          "subtitle": "Free up storage space",
          "icon": "clear_all",
          "type": "action"
        }
      ]
    },
    {
      "section": "Security",
      "items": [
        {
          "title": "Biometric Lock",
          "subtitle": "Use fingerprint or face unlock",
          "icon": "fingerprint",
          "type": "toggle",
          "value": false
        },
        {
          "title": "App PIN",
          "subtitle": "Set PIN for app access",
          "icon": "lock",
          "type": "action"
        }
      ]
    },
    {
      "section": "Display",
      "items": [
        {
          "title": "Theme",
          "subtitle": "System",
          "icon": "palette",
          "type": "theme"
        },
        {
          "title": "Text Size",
          "subtitle": "Medium",
          "icon": "text_fields",
          "type": "slider"
        },
        {
          "title": "Reduced Motion",
          "subtitle": "Minimize animations",
          "icon": "accessibility",
          "type": "toggle",
          "value": false
        }
      ]
    },
    {
      "section": "About",
      "items": [
        {
          "title": "App Version",
          "subtitle": "1.0.0 (Build 1)",
          "icon": "info",
          "type": "info"
        },
        {
          "title": "Privacy Policy",
          "subtitle": "View privacy policy",
          "icon": "privacy_tip",
          "type": "action"
        },
        {
          "title": "Terms of Service",
          "subtitle": "View terms and conditions",
          "icon": "description",
          "type": "action"
        },
        {
          "title": "Reset All Settings",
          "subtitle": "Restore default settings",
          "icon": "restore",
          "type": "reset"
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: 5);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LanguagePickerWidget(
        selectedLanguage: _selectedLanguage,
        onLanguageSelected: (language) {
          setState(() {
            _selectedLanguage = language;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Theme',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            ...['Light', 'Dark', 'System'].map((theme) => ListTile(
                  leading: CustomIconWidget(
                    iconName: theme == 'Light'
                        ? 'light_mode'
                        : theme == 'Dark'
                            ? 'dark_mode'
                            : 'settings',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(theme),
                  trailing: _selectedTheme == theme
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedTheme = theme;
                    });
                    Navigator.pop(context);
                  },
                )),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset All Settings'),
        content: Text(
            'This will restore all settings to their default values. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings reset successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'language':
        return ListTile(
          leading: CustomIconWidget(
            iconName: item['icon'],
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          title: Text(item['title']),
          subtitle: Text(_selectedLanguage),
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          onTap: _showLanguagePicker,
        );

      case 'toggle':
        bool value = item['title'] == 'Payment Reminders'
            ? _paymentReminders
            : item['title'] == 'Recovery Alerts'
                ? _recoveryAlerts
                : item['title'] == 'Daily Balance Summary'
                    ? _dailyBalanceSummary
                    : item['title'] == 'Biometric Lock'
                        ? _biometricEnabled
                        : _reducedMotion;

        return ListTile(
          leading: CustomIconWidget(
            iconName: item['icon'],
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          title: Text(item['title']),
          subtitle: Text(item['subtitle']),
          trailing: Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                if (item['title'] == 'Payment Reminders') {
                  _paymentReminders = newValue;
                } else if (item['title'] == 'Recovery Alerts') {
                  _recoveryAlerts = newValue;
                } else if (item['title'] == 'Daily Balance Summary') {
                  _dailyBalanceSummary = newValue;
                } else if (item['title'] == 'Biometric Lock') {
                  _biometricEnabled = newValue;
                } else if (item['title'] == 'Reduced Motion') {
                  _reducedMotion = newValue;
                }
              });
            },
          ),
        );

      case 'theme':
        return ListTile(
          leading: CustomIconWidget(
            iconName: item['icon'],
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          title: Text(item['title']),
          subtitle: Text(_selectedTheme),
          trailing: CustomIconWidget(
            iconName: 'chevron_right',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          onTap: _showThemePicker,
        );

      case 'slider':
        return ListTile(
          leading: CustomIconWidget(
            iconName: item['icon'],
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          title: Text(item['title']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medium'),
              SizedBox(height: 8),
              Slider(
                value: _textSize,
                min: 12.0,
                max: 20.0,
                divisions: 4,
                onChanged: (value) {
                  setState(() {
                    _textSize = value;
                  });
                },
              ),
            ],
          ),
        );

      case 'reset':
        return ListTile(
          leading: CustomIconWidget(
            iconName: item['icon'],
            color: AppTheme.lightTheme.colorScheme.error,
            size: 24,
          ),
          title: Text(
            item['title'],
            style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
          ),
          subtitle: Text(item['subtitle']),
          onTap: _showResetConfirmation,
        );

      case 'action':
        return ListTile(
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
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item['title']} feature coming soon')),
            );
          },
        );

      case 'firm_management':
        return ListTile(
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text('Firm Management'),
                    backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
                    foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
                  ),
                  body: SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: FirmManagementWidget(),
                  ),
                ),
              ),
            );
          },
        );

      default:
        return ListTile(
          leading: CustomIconWidget(
            iconName: item['icon'],
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          title: Text(item['title']),
          subtitle: Text(item['subtitle']),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'dashboard',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: 'Dashboard',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: 'Add Income',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'payment',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: 'Payment',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: 'History',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              text: 'Settings',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/dashboard');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/add-cash-income');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/record-payment');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/transaction-history');
                break;
              case 4:
                // Already on settings
                break;
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(), // Dashboard placeholder
          Container(), // Add Income placeholder
          Container(), // Payment placeholder
          Container(), // History placeholder
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2.h),
                ..._settingsData.map((section) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                          child: Text(
                            section['section'],
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 0.5.h),
                          child: Column(
                            children: [
                              ...(section['items'] as List)
                                  .map((item) => _buildSettingItem(item)),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                      ],
                    )),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
