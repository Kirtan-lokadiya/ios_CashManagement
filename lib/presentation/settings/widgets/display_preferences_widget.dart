import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DisplayPreferencesWidget extends StatefulWidget {
  final String selectedTheme;
  final double textSize;
  final bool reducedMotion;
  final Function(String) onThemeChanged;
  final Function(double) onTextSizeChanged;
  final Function(bool) onReducedMotionChanged;

  const DisplayPreferencesWidget({
    Key? key,
    required this.selectedTheme,
    required this.textSize,
    required this.reducedMotion,
    required this.onThemeChanged,
    required this.onTextSizeChanged,
    required this.onReducedMotionChanged,
  }) : super(key: key);

  @override
  State<DisplayPreferencesWidget> createState() =>
      _DisplayPreferencesWidgetState();
}

class _DisplayPreferencesWidgetState extends State<DisplayPreferencesWidget> {
  void _showThemeSelector() {
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
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'palette',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Select Theme',
                  style: AppTheme.lightTheme.textTheme.headlineSmall,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildThemeOption('Light', 'light_mode', 'Best for daytime use'),
            _buildThemeOption(
                'Dark', 'dark_mode', 'Easy on the eyes in low light'),
            _buildThemeOption('System', 'settings', 'Follows device settings'),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, String iconName, String description) {
    bool isSelected = widget.selectedTheme == theme;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        leading: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primaryContainer
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        title: Text(
          theme,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: isSelected ? AppTheme.lightTheme.colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTheme.lightTheme.textTheme.bodySmall,
        ),
        trailing: isSelected
            ? CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              )
            : null,
        onTap: () {
          widget.onThemeChanged(theme);
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getTextSizeLabel(double size) {
    if (size <= 14) return 'Small';
    if (size <= 16) return 'Medium';
    if (size <= 18) return 'Large';
    return 'Extra Large';
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
                  iconName: 'display_settings',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Display Preferences',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomIconWidget(
                iconName: 'palette',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Theme'),
              subtitle: Text(widget.selectedTheme),
              trailing: CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onTap: _showThemeSelector,
            ),
            Divider(height: 3.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomIconWidget(
                iconName: 'text_fields',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Text Size'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getTextSizeLabel(widget.textSize)),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Text('A', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: widget.textSize,
                          min: 12.0,
                          max: 20.0,
                          divisions: 4,
                          onChanged: widget.onTextSizeChanged,
                        ),
                      ),
                      Text('A', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 3.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomIconWidget(
                iconName: 'accessibility',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Reduced Motion'),
              subtitle: Text('Minimize animations for better accessibility'),
              trailing: Switch(
                value: widget.reducedMotion,
                onChanged: widget.onReducedMotionChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
