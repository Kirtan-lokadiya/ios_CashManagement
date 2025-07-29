import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/suggestion_model.dart';

class SourceInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final Function(String) onChanged;

  const SourceInputWidget({
    Key? key,
    required this.controller,
    required this.suggestions,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SourceInputWidget> createState() => _SourceInputWidgetState();
}

class _SourceInputWidgetState extends State<SourceInputWidget> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;
  List<String> _allSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
    _loadSuggestions();
  }

  void _loadSuggestions() {
    final box = Hive.box<Suggestion>('suggestions');
    setState(() {
      _allSuggestions = box.values
        .where((s) => s.type == 'source')
        .map((s) => s.value)
        .toList();
      if (_allSuggestions.isEmpty) {
        final defaults = [
          'Salary',
          'Freelance Work',
          'Business Revenue',
          'Investment Returns',
          'Gift Money',
          'Bonus',
          'Commission',
          'Rental Income',
        ];
        for (final val in defaults) {
          box.add(Suggestion(value: val, type: 'source'));
        }
        _allSuggestions = defaults;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _filterSuggestions(widget.controller.text);
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged() async {
    _filterSuggestions(widget.controller.text);
    if (_focusNode.hasFocus) {
      _showSuggestionsOverlay();
    }
    // Add new suggestion to Hive if not present and not empty
    final text = widget.controller.text.trim();
    if (text.isNotEmpty && !_allSuggestions.contains(text)) {
      final box = Hive.box<Suggestion>('suggestions');
      await box.add(Suggestion(value: text, type: 'source'));
      setState(() {
        _allSuggestions.add(text);
      });
    }
  }

  void _filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = _allSuggestions;
      } else {
        _filteredSuggestions = _allSuggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _showSuggestions = _filteredSuggestions.isNotEmpty && query.isNotEmpty;
    });
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();

    if (!_showSuggestions || _filteredSuggestions.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - (8.w),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 6.h),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(maxHeight: 30.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredSuggestions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      suggestion,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    leading: CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: () {
                      widget.controller.text = suggestion;
                      widget.onChanged(suggestion);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Source Description *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: AppTheme.lightTheme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'e.g., Salary, Freelance, Business',
              hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        widget.controller.clear();
                        widget.onChanged('');
                        _removeOverlay();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'clear',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
            ),
            onChanged: widget.onChanged,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Source description is required';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Describe where this money came from',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
