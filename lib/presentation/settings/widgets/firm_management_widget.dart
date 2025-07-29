import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/firm_model.dart';
import '../../../core/transaction_model.dart';

class FirmManagementWidget extends StatefulWidget {
  const FirmManagementWidget({Key? key}) : super(key: key);

  @override
  State<FirmManagementWidget> createState() => _FirmManagementWidgetState();
}

class _FirmManagementWidgetState extends State<FirmManagementWidget> {
  final TextEditingController _firmNameController = TextEditingController();
  final TextEditingController _firmDescriptionController = TextEditingController();
  final TextEditingController _transferAmountController = TextEditingController();
  
  Firm? _selectedFromFirm;
  Firm? _selectedToFirm;

  @override
  void dispose() {
    _firmNameController.dispose();
    _firmDescriptionController.dispose();
    _transferAmountController.dispose();
    super.dispose();
  }

  double _calculateFirmBalance(String firmId) {
    final box = Hive.box<Transaction>('transactions');
    double balance = 0.0;
    for (var transaction in box.values) {
      if (transaction.firmId == firmId) {
        if (transaction.type == 'income') {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }
    }
    return balance;
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
                setState(() {});
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFirmDialog(Firm firm) {
    final balance = _calculateFirmBalance(firm.id);
    final transactionCount = Hive.box<Transaction>('transactions')
        .values
        .where((t) => t.firmId == firm.id)
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Firm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${firm.name}"?'),
            SizedBox(height: 1.h),
            Text('This will also delete:'),
            Text('• $transactionCount transactions'),
            Text('• ₹${balance.toStringAsFixed(2)} balance'),
            SizedBox(height: 1.h),
            Text('This action cannot be undone!', 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Delete all transactions for this firm
              final transactionBox = Hive.box<Transaction>('transactions');
              final transactionsToDelete = transactionBox.values
                  .where((t) => t.firmId == firm.id)
                  .toList();
              for (var transaction in transactionsToDelete) {
                await transaction.delete();
              }
              
              // Delete the firm
              await firm.delete();
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTransferBalanceDialog() {
    _transferAmountController.clear();
    _selectedFromFirm = null;
    _selectedToFirm = null;
    
    final firms = Hive.box<Firm>('firms').values.toList();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Transfer Balance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Firm>(
                value: _selectedFromFirm,
                decoration: InputDecoration(labelText: 'From Firm'),
                items: firms.map((firm) {
                  final balance = _calculateFirmBalance(firm.id);
                  return DropdownMenuItem(
                    value: firm,
                    child: Text('${firm.name} (₹${balance.toStringAsFixed(2)})'),
                  );
                }).toList(),
                onChanged: (firm) {
                  setDialogState(() => _selectedFromFirm = firm);
                },
              ),
              SizedBox(height: 2.h),
              DropdownButtonFormField<Firm>(
                value: _selectedToFirm,
                decoration: InputDecoration(labelText: 'To Firm'),
                items: firms.map((firm) {
                  final balance = _calculateFirmBalance(firm.id);
                  return DropdownMenuItem(
                    value: firm,
                    child: Text('${firm.name} (₹${balance.toStringAsFixed(2)})'),
                  );
                }).toList(),
                onChanged: (firm) {
                  setDialogState(() => _selectedToFirm = firm);
                },
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _transferAmountController,
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
                if (_selectedFromFirm != null && 
                    _selectedToFirm != null && 
                    _selectedFromFirm != _selectedToFirm &&
                    _transferAmountController.text.isNotEmpty) {
                  
                  final amount = double.tryParse(_transferAmountController.text);
                  if (amount != null && amount > 0) {
                    final fromBalance = _calculateFirmBalance(_selectedFromFirm!.id);
                    if (amount <= fromBalance) {
                      // Create transfer transactions
                      final transactionBox = Hive.box<Transaction>('transactions');
                      
                      // Debit from source firm
                      await transactionBox.add(Transaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: 'expense',
                        amount: amount,
                        recipient: _selectedToFirm!.name,
                        source: null,
                        description: 'Transfer to ${_selectedToFirm!.name}',
                        date: DateTime.now(),
                        category: 'Transfer',
                        phone: null,
                        firmId: _selectedFromFirm!.id,
                      ));
                      
                      // Credit to destination firm
                      await transactionBox.add(Transaction(
                        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
                        type: 'income',
                        amount: amount,
                        recipient: null,
                        source: _selectedFromFirm!.name,
                        description: 'Transfer from ${_selectedFromFirm!.name}',
                        date: DateTime.now(),
                        category: 'Transfer',
                        phone: null,
                        firmId: _selectedToFirm!.id,
                      ));
                      
                      Navigator.pop(context);
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Insufficient balance in source firm')),
                      );
                    }
                  }
                }
              },
              child: Text('Transfer'),
            ),
          ],
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Firm Management',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showTransferBalanceDialog,
                      icon: Icon(Icons.swap_horiz),
                      label: Text('Transfer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    ElevatedButton.icon(
                      onPressed: _showAddFirmDialog,
                      icon: Icon(Icons.add),
                      label: Text('Add Firm'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            
            if (firms.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.business, size: 50, color: Colors.grey),
                    SizedBox(height: 2.h),
                    Text('No firms created yet'),
                    SizedBox(height: 1.h),
                    Text('Create your first firm to start managing business finances'),
                    SizedBox(height: 2.h),
                    ElevatedButton.icon(
                      onPressed: _showAddFirmDialog,
                      icon: Icon(Icons.add),
                      label: Text('Create First Firm'),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: firms.length,
                itemBuilder: (context, index) {
                  final firm = firms[index];
                  final balance = _calculateFirmBalance(firm.id);
                  final transactionCount = Hive.box<Transaction>('transactions')
                      .values
                      .where((t) => t.firmId == firm.id)
                      .length;
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(4.w),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                        child: Text(
                          firm.name[0].toUpperCase(),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        firm.name,
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (firm.description?.isNotEmpty == true)
                            Text(firm.description!),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Balance: ₹${balance.toStringAsFixed(2)} • $transactionCount transactions',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete', style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            // TODO: Implement edit functionality
                          } else if (value == 'delete') {
                            _showDeleteFirmDialog(firm);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
} 