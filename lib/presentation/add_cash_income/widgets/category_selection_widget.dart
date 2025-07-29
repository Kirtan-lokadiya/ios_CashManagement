import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/suggestion_model.dart';

class CategorySelectionWidget extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelectionWidget({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelectionWidget> createState() =>
      _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  List<String> _categories = [];
  final TextEditingController _customCategoryController = TextEditingController();
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final box = Hive.box<Suggestion>('suggestions');
    setState(() {
      _categories = box.values
        .where((s) => s.type == 'category')
        .map((s) => s.value)
        .toList();
      if (_categories.isEmpty) {
        final defaults = [
          'Business',
          'Salary',
          'Investment',
          'Gift',
          'Other',
        ];
        for (final val in defaults) {
          box.add(Suggestion(value: val, type: 'category'));
        }
        _categories = defaults;
      }
    });
  }

  void _showCustomCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Custom Category',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _customCategoryController,
              autofocus: true,
              style: AppTheme.lightTheme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Enter category name',
                hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 3.w,
                ),
              ),
              maxLength: 20,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _customCategoryController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final customCategory = _customCategoryController.text.trim();
              if (customCategory.isNotEmpty) {
                final box = Hive.box<Suggestion>('suggestions');
                if (!_categories.contains(customCategory)) {
                  await box.add(Suggestion(value: customCategory, type: 'category'));
                  setState(() {
                    _categories.add(customCategory);
                  });
                }
                widget.onCategorySelected(customCategory);
                _customCategoryController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            itemCount: _categories.length + 1, // +1 for custom category option
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              if (index == _categories.length) {
                return _buildCustomCategoryChip();
              }
              final categoryName = _categories[index];
              final isSelected = widget.selectedCategory == categoryName;
              return _buildCategoryChip(
                name: categoryName,
                icon: 'label',
                color: AppTheme.lightTheme.colorScheme.primary,
                isSelected: isSelected,
                onTap: () => widget.onCategorySelected(categoryName),
              );
            },
          ),
        ),
        if (widget.selectedCategory.isNotEmpty &&
            !_categories.contains(widget.selectedCategory)) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'label',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Custom: ${widget.selectedCategory}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => widget.onCategorySelected(''),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 1.h),
        Text(
          'Select or create a category for this income',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String name,
    required String icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.lightTheme.colorScheme.outline,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
                iconName: icon,
              color: color,
                size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              name,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCategoryChip() {
    return GestureDetector(
      onTap: _showCustomCategoryDialog,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              'Custom',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
