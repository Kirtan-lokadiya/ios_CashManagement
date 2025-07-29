import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/suggestion_model.dart';

class PurposeNotesWidget extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String>? onChanged;

  const PurposeNotesWidget({
    Key? key,
    required this.controller,
    required this.suggestions,
    this.onChanged,
  }) : super(key: key);

  @override
  State<PurposeNotesWidget> createState() => _PurposeNotesWidgetState();
}

class _PurposeNotesWidgetState extends State<PurposeNotesWidget> {
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];
  List<String> _allSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    widget.controller.addListener(() => _onTextChanged(widget.controller.text));
  }

  void _loadSuggestions() {
    final box = Hive.box<Suggestion>('suggestions');
    setState(() {
      _allSuggestions = box.values
        .where((s) => s.type == 'purpose')
        .map((s) => s.value)
        .toList();
      if (_allSuggestions.isEmpty) {
        final defaults = [
          'Grocery shopping',
          'Fuel expense',
          'Medical bills',
          'Loan repayment',
          'Business supplies',
          'Utility bills',
          'Food & dining',
          'Transportation',
        ];
        for (final val in defaults) {
          box.add(Suggestion(value: val, type: 'purpose'));
        }
        _allSuggestions = defaults;
      }
      _filteredSuggestions = _allSuggestions;
    });
  }

  void _onTextChanged(String text) async {
    setState(() {
      if (text.isEmpty) {
        _showSuggestions = false;
        _filteredSuggestions = _allSuggestions;
      } else {
        _showSuggestions = true;
        _filteredSuggestions = _allSuggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(text.toLowerCase()))
            .toList();
      }
    });
    // Add new suggestion to Hive if not present and not empty
    if (text.isNotEmpty && !_allSuggestions.contains(text)) {
      final box = Hive.box<Suggestion>('suggestions');
      await box.add(Suggestion(value: text, type: 'purpose'));
      setState(() {
        _allSuggestions.add(text);
      });
    }
  }

  void _selectSuggestion(String suggestion) {
    widget.controller.text = suggestion;
    widget.onChanged?.call(suggestion);
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purpose / Notes',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),

        // Text field
        TextFormField(
          controller: widget.controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter payment purpose or notes...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: 3.w, left: 3.w, right: 3.w),
              child: CustomIconWidget(
                iconName: 'note_alt',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  )
                : null,
          ),
          onChanged: _onTextChanged,
          onTap: () {
            if (widget.controller.text.isEmpty) {
              setState(() {
                _showSuggestions = true;
              });
            }
          },
        ),

        // Suggestions
        if (_showSuggestions && _filteredSuggestions.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: 25.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb_outline',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Suggestions',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _filteredSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _filteredSuggestions[index];
                      return ListTile(
                        dense: true,
                        leading: CustomIconWidget(
                          iconName: 'history',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        title: Text(
                          suggestion,
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        onTap: () => _selectSuggestion(suggestion),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],

        // Quick purpose chips
        if (!_showSuggestions) ...[
          SizedBox(height: 1.h),
          Text(
            'Quick Options',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.suggestions.take(6).map((suggestion) {
              return GestureDetector(
                onTap: () => _selectSuggestion(suggestion),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
