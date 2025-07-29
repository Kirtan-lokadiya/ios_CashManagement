import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotesInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const NotesInputWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<NotesInputWidget> createState() => _NotesInputWidgetState();
}

class _NotesInputWidgetState extends State<NotesInputWidget> {
  final FocusNode _focusNode = FocusNode();
  static const int _maxLength = 200;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: 4,
          maxLength: _maxLength,
          style: AppTheme.lightTheme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Add any additional details about this income...',
            hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: 3.w,
                right: 2.w,
                top: 3.w,
              ),
              child: CustomIconWidget(
                iconName: 'note_add',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 3.w,
                        top: 3.w,
                      ),
                      child: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 4.w,
            ),
            counterStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          onChanged: widget.onChanged,
        ),
        SizedBox(height: 1.h),
        Text(
          'Optional notes to help you remember details about this income',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
