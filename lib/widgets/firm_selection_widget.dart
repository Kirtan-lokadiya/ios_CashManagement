import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../core/firm_model.dart';

class FirmSelectionWidget extends StatefulWidget {
  final String? selectedFirmId;
  final Function(String) onFirmSelected;
  final bool isRequired;

  const FirmSelectionWidget({
    Key? key,
    this.selectedFirmId,
    required this.onFirmSelected,
    this.isRequired = true,
  }) : super(key: key);

  @override
  State<FirmSelectionWidget> createState() => _FirmSelectionWidgetState();
}

class _FirmSelectionWidgetState extends State<FirmSelectionWidget> {
  final TextEditingController _firmNameController = TextEditingController();
  final TextEditingController _firmDescriptionController = TextEditingController();

  @override
  void dispose() {
    _firmNameController.dispose();
    _firmDescriptionController.dispose();
    super.dispose();
  }

  void _showAddFirmDialog() {
    _firmNameController.clear();
    _firmDescriptionController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Firm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _firmNameController,
              decoration: InputDecoration(
                labelText: 'Firm Name *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _firmDescriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_firmNameController.text.trim().isNotEmpty) {
                final firm = Firm(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _firmNameController.text.trim(),
                  description: _firmDescriptionController.text.trim(),
                  createdAt: DateTime.now(),
                );
                final box = Hive.box<Firm>('firms');
                await box.add(firm);
                Navigator.pop(context);
                widget.onFirmSelected(firm.id);
                setState(() {});
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Firm>('firms').listenable(),
      builder: (context, Box<Firm> box, _) {
        final firms = box.values.toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Firm ${widget.isRequired ? '*' : ''}',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            
            if (firms.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.business,
                      size: 40,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No firms created yet',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Create your first firm to continue',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton.icon(
                      onPressed: _showAddFirmDialog,
                      icon: Icon(Icons.add),
                      label: Text('Create First Firm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: widget.selectedFirmId,
                      decoration: InputDecoration(
                        labelText: 'Select Firm',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: firms.map((firm) {
                        return DropdownMenuItem(
                          value: firm.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 3.w,
                                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                                child: Text(
                                  firm.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      firm.name,
                                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (firm.description?.isNotEmpty == true)
                                      Text(
                                        firm.description!,
                                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (firmId) {
                        if (firmId != null) {
                          widget.onFirmSelected(firmId);
                        }
                      },
                    ),
                    SizedBox(height: 2.h),
                    OutlinedButton.icon(
                      onPressed: _showAddFirmDialog,
                      icon: Icon(Icons.add),
                      label: Text('Add New Firm'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                        side: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
} 