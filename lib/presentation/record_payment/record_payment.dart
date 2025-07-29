import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/amount_input_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/payment_type_widget.dart';
import './widgets/purpose_notes_widget.dart';
import './widgets/recipient_selection_widget.dart';
import './widgets/reminder_settings_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/transaction_model.dart';
import '../../core/suggestion_model.dart';
import '../../widgets/firm_selection_widget.dart';

class RecordPayment extends StatefulWidget {
  const RecordPayment({Key? key}) : super(key: key);

  @override
  State<RecordPayment> createState() => _RecordPaymentState();
}

class _RecordPaymentState extends State<RecordPayment> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _purposeController = TextEditingController();

  double _currentBalance = 0.0;
  String _selectedPaymentType = 'Personal';
  String? _selectedFirmId;
  DateTime _selectedDate = DateTime.now();
  bool _isReminderEnabled = false;
  DateTime? _reminderDate;
  String _reminderFrequency = 'One-time';
  bool _useContactPicker = false;
  String? _selectedContactName;
  String? _selectedContactPhone;

  List<String> _paymentTypes = [];
  final List<String> _reminderFrequencies = ['One-time', 'Monthly', 'Weekly'];
  List<String> _purposeSuggestions = [];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => _onAmountChanged(_amountController.text));
    _purposeController.addListener(() => _onAmountChanged(_purposeController.text));
    _loadSuggestions();
    _loadCurrentBalance();
  }

  void _loadSuggestions() {
    final box = Hive.box<Suggestion>('suggestions');
    setState(() {
      _paymentTypes = box.values
        .where((s) => s.type == 'paymentType')
        .map((s) => s.value)
        .toList();
      if (_paymentTypes.isEmpty) {
        final defaults = ['Loan', 'EMI', 'Business', 'Personal', 'Other'];
        for (final val in defaults) {
          box.add(Suggestion(value: val, type: 'paymentType'));
        }
        _paymentTypes = defaults;
      }
      _purposeSuggestions = box.values
        .where((s) => s.type == 'purpose')
        .map((s) => s.value)
        .toList();
      if (_purposeSuggestions.isEmpty) {
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
        _purposeSuggestions = defaults;
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
    _nameController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    setState(() {
      // Update balance calculation in real-time
    });
  }

  void _onContactSelected(String name, String phone) {
    setState(() {
      _selectedContactName = name;
      _selectedContactPhone = phone;
      _useContactPicker = true;
    });
  }

  void _onManualEntrySelected() {
    setState(() {
      _useContactPicker = false;
      _selectedContactName = null;
      _selectedContactPhone = null;
    });
  }

  void _onPaymentTypeChanged(String type) {
    setState(() {
      _selectedPaymentType = type;
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onReminderToggled(bool enabled) {
    setState(() {
      _isReminderEnabled = enabled;
      if (!enabled) {
        _reminderDate = null;
      }
    });
  }

  void _onReminderDateChanged(DateTime? date) {
    setState(() {
      _reminderDate = date;
    });
  }

  void _onReminderFrequencyChanged(String frequency) {
    setState(() {
      _reminderFrequency = frequency;
    });
  }

  double get _enteredAmount {
    final text = _amountController.text.replaceAll(',', '');
    return double.tryParse(text) ?? 0.0;
  }

  double get _remainingBalance {
    return _currentBalance - _enteredAmount;
  }

  void _savePayment() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_enteredAmount <= 0) {
        _showErrorSnackBar('Please enter a valid amount');
        return;
      }
      if (_enteredAmount > _currentBalance) {
        _showErrorSnackBar('Insufficient balance');
        return;
      }
      if (_selectedFirmId == null) {
        _showErrorSnackBar('Please select a firm');
        return;
      }
      if (!_useContactPicker &&
          (_nameController.text.isEmpty || _phoneController.text.isEmpty)) {
        _showErrorSnackBar('Please enter recipient details');
        return;
      }
      if (_useContactPicker &&
          (_selectedContactName == null || _selectedContactPhone == null)) {
        _showErrorSnackBar('Please select a contact');
        return;
      }
      if (_isReminderEnabled && _reminderDate == null) {
        _showErrorSnackBar('Please select reminder date');
        return;
      }
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'expense',
        amount: _enteredAmount,
        recipient: _useContactPicker ? _selectedContactName : _nameController.text,
        source: null,
        description: _purposeController.text,
        date: _selectedDate,
        category: _selectedPaymentType,
        phone: _useContactPicker ? _selectedContactPhone : _phoneController.text,
        firmId: _selectedFirmId!,
      );
      final transactionBox = Hive.box<Transaction>('transactions');
      await transactionBox.add(transaction);
      // Add new payment type suggestion if not already present
      final suggestionBox = Hive.box<Suggestion>('suggestions');
      if (!_paymentTypes.contains(_selectedPaymentType)) {
        await suggestionBox.add(Suggestion(value: _selectedPaymentType, type: 'paymentType'));
      }
      if (!_purposeSuggestions.contains(_purposeController.text)) {
        await suggestionBox.add(Suggestion(value: _purposeController.text, type: 'purpose'));
      }
      _showSuccessSnackBar('Payment recorded successfully');
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, transaction);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          elevation: AppTheme.lightTheme.appBarTheme.elevation,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          title: Text(
            'Record Payment',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: _savePayment,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 2.w),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
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
                        AmountInputWidget(
                          controller: _amountController,
                          onChanged: (value) => _onAmountChanged(value),
                          currentBalance: _currentBalance,
                        ),
                        SizedBox(height: 3.h),
                        RecipientSelectionWidget(
                          nameController: _nameController,
                          phoneController: _phoneController,
                          useContactPicker: _useContactPicker,
                          selectedContactName: _selectedContactName,
                          selectedContactPhone: _selectedContactPhone,
                          onContactSelected: _onContactSelected,
                          onManualEntrySelected: _onManualEntrySelected,
                        ),
                        SizedBox(height: 3.h),
                        PaymentTypeWidget(
                          selectedType: _selectedPaymentType,
                          onTypeChanged: _onPaymentTypeChanged,
                        ),
                        SizedBox(height: 3.h),
                        DatePickerWidget(
                          selectedDate: _selectedDate,
                          onDateChanged: _onDateChanged,
                        ),
                        SizedBox(height: 3.h),
                        PurposeNotesWidget(
                          controller: _purposeController,
                          suggestions: _purposeSuggestions,
                          onChanged: (value) => _onAmountChanged(value),
                        ),
                        SizedBox(height: 3.h),
                        ReminderSettingsWidget(
                          isEnabled: _isReminderEnabled,
                          reminderDate: _reminderDate,
                          frequency: _reminderFrequency,
                          frequencies: _reminderFrequencies,
                          onToggled: (val) {
                            setState(() {
                              _isReminderEnabled = val;
                            });
                          },
                          onDateChanged: (date) {
                            setState(() {
                              _reminderDate = date;
                            });
                          },
                          onFrequencyChanged: (freq) {
                            setState(() {
                              _reminderFrequency = freq;
                            });
                          },
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
}
