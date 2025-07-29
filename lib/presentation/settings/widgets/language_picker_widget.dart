import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LanguagePickerWidget extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguagePickerWidget({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> languages = [
      {
        "name": "English",
        "nativeName": "English",
        "code": "en",
        "flag": "🇺🇸"
      },
      {"name": "Hindi", "nativeName": "हिंदी", "code": "hi", "flag": "🇮🇳"},
      {
        "name": "Gujarati",
        "nativeName": "ગુજરાતી",
        "code": "gu",
        "flag": "🇮🇳"
      }
    ];

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'language',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Select Language',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...languages.map((language) => Container(
                margin: EdgeInsets.only(bottom: 1.h),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  leading: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        language['flag'],
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ),
                  title: Text(
                    language['name'],
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    language['nativeName'],
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: selectedLanguage == language['name']
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        )
                      : CustomIconWidget(
                          iconName: 'radio_button_unchecked',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                  onTap: () => onLanguageSelected(language['name']),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
