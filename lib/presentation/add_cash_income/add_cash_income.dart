import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_selection_widget.dart';
import './widgets/date_time_picker_widget.dart';
import './widgets/notes_input_widget.dart';
import './widgets/source_input_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/transaction_model.dart';
import '../../core/suggestion_model.dart';
import '../../widgets/firm_selection_widget.dart';

class AddCashIncome extends StatefulWidget {
  const AddCashIncome({Key? key}) : super(key: key);

  @override
  State<AddCashIncome> createState() => _AddCashIncomeState();
}

class _AddCashIncomeState extends State<AddCashIncome> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  String _selectedCategory = '';
  String? _selectedFirmId;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  List<String> _sourceSuggestions = [];
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onFormChanged);
    _sourceController.addListener(_onFormChanged);
    _notesController.addListener(_onFormChanged);
    _loadSuggestions();
    _loadCurrentBalance();
  }

  void _loadSuggestions() {
    final box = Hive.box<Suggestion>('suggestions');
    setState(() {
      _sourceSuggestions = box.values
        .where((s) => s.type == 'source')
        .map((s) => s.value)
        .toList();
      // If no suggestions, add defaults
      if (_sourceSuggestions.isEmpty) {
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
        _sourceSuggestions = defaults;
      }
    });
  }

  void _loadCurrentBalance() {
    final box = Hive.box<Transaction>('transactions');
    double balance = 0.0;
    for (var transaction in box.values) {
      if (transaction.type == 'income') {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    setState(() {
      _currentBalance = balance;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  bool get _isFormValid {
    return _amountController.text.isNotEmpty &&
        _sourceController.text.isNotEmpty &&
        _selectedCategory.isNotEmpty &&
        _selectedFirmId != null &&
        double.tryParse(_amountController.text.replaceAll(',', '')) != null;
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Discard Changes?',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              content: Text(
                'You have unsaved changes. Are you sure you want to leave?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  void _saveIncome() async {
    if (!_isFormValid) return;
    setState(() {
      _isLoading = true;
    });
    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'income',
      amount: amount,
      recipient: null,
      source: _sourceController.text,
      description: _notesController.text,
      date: _selectedDateTime,
      category: _selectedCategory,
      phone: null,
      firmId: _selectedFirmId!,
    );
    final transactionBox = Hive.box<Transaction>('transactions');
    await transactionBox.add(transaction);
    // Add new source suggestion if not already present
    final suggestionBox = Hive.box<Suggestion>('suggestions');
    if (!_sourceSuggestions.contains(_sourceController.text)) {
      await suggestionBox.add(Suggestion(value: _sourceController.text, type: 'source'));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Income of ₹${_formatCurrency(amount)} added successfully!'),
          backgroundColor: AppTheme.getSuccessColor(true),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    }
    setState(() {
      _isLoading = false;
    });
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Firm Selection at the very top ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FirmSelectionWidget(
                                selectedFirmId: _selectedFirmId,
                                onFirmSelected: (firmId) {
                                  setState(() {
                                    _selectedFirmId = firmId;
                                    _hasUnsavedChanges = true;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.settings),
                              tooltip: 'Manage Firms',
                              onPressed: () {
                                Navigator.pushNamed(context, '/settings');
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        // --- End Firm Selection ---
                        _buildBalanceReference(),
                        SizedBox(height: 3.h),
                        AmountInputWidget(
                          controller: _amountController,
                          onChanged: (value) => _onFormChanged(),
                        ),
                        SizedBox(height: 3.h),
                        SourceInputWidget(
                          controller: _sourceController,
                          suggestions: _sourceSuggestions,
                          onChanged: (value) => _onFormChanged(),
                        ),
                        SizedBox(height: 3.h),
                        CategorySelectionWidget(
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),
                        DateTimePickerWidget(
                          selectedDateTime: _selectedDateTime,
                          onDateTimeChanged: (dateTime) {
                            setState(() {
                              _selectedDateTime = dateTime;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),
                        NotesInputWidget(
                          controller: _notesController,
                          onChanged: (value) => _onFormChanged(),
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Add Cash Income',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _isFormValid && !_isLoading ? _saveIncome : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
              decoration: BoxDecoration(
                color: _isFormValid && !_isLoading
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Save',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: _isFormValid
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceReference() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '₹${_formatCurrency(_currentBalance)}',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
