import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;

import '../../../core/app_export.dart';
import '../../../core/contact_model.dart' as app_contact;

class RecipientSelectionWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool useContactPicker;
  final String? selectedContactName;
  final String? selectedContactPhone;
  final Function(String, String) onContactSelected;
  final VoidCallback onManualEntrySelected;

  const RecipientSelectionWidget({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.useContactPicker,
    required this.selectedContactName,
    required this.selectedContactPhone,
    required this.onContactSelected,
    required this.onManualEntrySelected,
  }) : super(key: key);

  @override
  State<RecipientSelectionWidget> createState() =>
      _RecipientSelectionWidgetState();
}

class _RecipientSelectionWidgetState extends State<RecipientSelectionWidget> {
  List<flutter_contacts.Contact> _allContacts = [];
  List<flutter_contacts.Contact> _filteredContacts = [];
  bool _loadingContacts = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _showContactPicker() async {
    final hasPermission = await flutter_contacts.FlutterContacts.requestPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to access contacts')),
      );
      return;
    }

    setState(() {
      _loadingContacts = true;
    });

    try {
      final contacts = await flutter_contacts.FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _loadingContacts = false;
      });
    } catch (e) {
      setState(() {
        _loadingContacts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contacts: $e')),
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((c) {
          final name = c.displayName.toLowerCase();
          final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
          return name.contains(query.toLowerCase()) || phone.contains(query);
        }).toList();
      }
    });
  }

  Widget _buildContactPickerSheet() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Contact',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Contacts list
          Expanded(
            child: _loadingContacts
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                return _buildContactTile(contact);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(flutter_contacts.Contact contact) {
    final name = contact.displayName;
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
    final hasPhoto = contact.photo != null;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        backgroundImage: hasPhoto ? MemoryImage(contact.photo!) : null,
        child: !hasPhoto
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(name),
      subtitle: Text(phone),
      onTap: () {
        widget.onContactSelected(name, phone);
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipient Details',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),

        // Contact selection buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showContactPicker,
                icon: CustomIconWidget(
                  iconName: 'contacts',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: Text('Select Contact'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  side: BorderSide(
                    color: widget.useContactPicker
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: widget.useContactPicker ? 2 : 1,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onManualEntrySelected,
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: Text('Manual Entry'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  side: BorderSide(
                    color: !widget.useContactPicker
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: !widget.useContactPicker ? 2 : 1,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Selected contact display or manual entry fields
        widget.useContactPicker && widget.selectedContactName != null
            ? _buildSelectedContactCard()
            : _buildManualEntryFields(),
      ],
    );
  }

  Widget _buildSelectedContactCard() {
    return Container(
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 6.w,
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            child: Text(
              widget.selectedContactName![0].toUpperCase(),
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedContactName!,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.selectedContactPhone!,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onContactSelected('', '');
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntryFields() {
    return Column(
      children: [
        TextFormField(
          controller: widget.nameController,
          decoration: InputDecoration(
            labelText: 'Recipient Name',
            hintText: 'Enter recipient name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (!widget.useContactPicker && (value == null || value.isEmpty)) {
              return 'Please enter recipient name';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter phone number',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'phone',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (!widget.useContactPicker && (value == null || value.isEmpty)) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
