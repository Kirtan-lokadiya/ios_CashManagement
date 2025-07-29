import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecuritySettingsWidget extends StatefulWidget {
  final bool biometricEnabled;
  final Function(bool) onBiometricToggle;

  const SecuritySettingsWidget({
    Key? key,
    required this.biometricEnabled,
    required this.onBiometricToggle,
  }) : super(key: key);

  @override
  State<SecuritySettingsWidget> createState() => _SecuritySettingsWidgetState();
}

class _SecuritySettingsWidgetState extends State<SecuritySettingsWidget> {
  bool _hasBiometrics = true; // Mock biometric availability

  void _showPinSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'lock',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Set App PIN'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create a 4-digit PIN to secure your app'),
            SizedBox(height: 3.h),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Enter PIN',
                counterText: '',
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                counterText: '',
              ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PIN set successfully')),
              );
            },
            child: Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  void _showBiometricDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'fingerprint',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Biometric Authentication'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enable biometric authentication to secure your app with:'),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'fingerprint',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text('Fingerprint'),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'face',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text('Face ID'),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'You can always use your PIN as a backup',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
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
              widget.onBiometricToggle(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Biometric authentication enabled')),
              );
            },
            child: Text('Enable'),
          ),
        ],
      ),
    );
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
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Security Settings',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomIconWidget(
                iconName: 'fingerprint',
                color: _hasBiometrics
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              title: Text('Biometric Lock'),
              subtitle: Text(
                _hasBiometrics
                    ? 'Use fingerprint or face unlock'
                    : 'Biometric authentication not available',
              ),
              trailing: Switch(
                value: widget.biometricEnabled && _hasBiometrics,
                onChanged: _hasBiometrics
                    ? (value) {
                        if (value) {
                          _showBiometricDialog();
                        } else {
                          widget.onBiometricToggle(false);
                        }
                      }
                    : null,
              ),
            ),
            Divider(height: 3.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('App PIN'),
              subtitle: Text('Set PIN for app access'),
              trailing: CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onTap: _showPinSetupDialog,
            ),
            Divider(height: 3.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomIconWidget(
                iconName: 'auto_delete',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Auto-lock Timer'),
              subtitle: Text('Lock app after 5 minutes of inactivity'),
              trailing: CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Auto-lock settings coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
