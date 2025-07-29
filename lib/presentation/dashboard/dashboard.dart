import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/balance_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/quick_action_card_widget.dart';
import './widgets/recent_transaction_card_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/transaction_model.dart';
import '../../core/firm_model.dart';
import 'package:collection/collection.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isBalanceVisible = true;
  bool _isRefreshing = false;
  double _currentBalance = 0.0;
  DateTime _lastUpdated = DateTime.now();

  Box<Transaction>? _transactionBox;

  List<Map<String, dynamic>> get _quickActions => [
    {
      "title": "Add Cash Income",
      "description": "Record money received",
      "icon": "add_circle",
      "color": AppTheme.getSuccessColor(true),
      "route": "/add-cash-income"
    },
    {
      "title": "Record Payment",
      "description": "Log money spent",
      "icon": "remove_circle",
      "color": AppTheme.lightTheme.colorScheme.error,
      "route": "/record-payment"
    },
    {
      "title": "Set Reminder",
      "description": "Payment due alerts",
      "icon": "notifications",
      "color": AppTheme.getWarningColor(true),
      "route": "/settings"
    },
    {
      "title": "View Pending",
      "description": "Money to recover",
      "icon": "schedule",
      "color": AppTheme.lightTheme.colorScheme.primary,
      "route": "/transaction-history"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _transactionBox = Hive.box<Transaction>('transactions');
    _calculateBalance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateBalance() {
    double globalBalance = 0.0;
    final transactions = _transactionBox?.values.toList() ?? [];
    for (var transaction in transactions) {
      if (transaction.type == "income") {
        globalBalance += transaction.amount;
      } else {
        globalBalance -= transaction.amount;
      }
    }
    setState(() {
      _currentBalance = globalBalance;
      _lastUpdated = DateTime.now();
    });
  }

  Map<String, double> _calculateFirmBalances() {
    final firms = Hive.box<Firm>('firms').values.toList();
    final transactions = _transactionBox?.values.toList() ?? [];
    Map<String, double> firmBalances = {};
    
    for (var firm in firms) {
      double balance = 0.0;
      for (var transaction in transactions) {
        if (transaction.firmId == firm.id) {
          if (transaction.type == "income") {
            balance += transaction.amount;
          } else {
            balance -= transaction.amount;
          }
        }
      }
      firmBalances[firm.id] = balance;
    }
    
    return firmBalances;
  }

  String _getFirmName(String firmId) {
    final firm = Hive.box<Firm>('firms').values.firstWhereOrNull((f) => f.id == firmId);
    return firm?.name ?? 'Unknown Firm';
  }

  Future<void> _refreshBalance() async {
    setState(() {
      _isRefreshing = true;
    });
    await Future.delayed(Duration(milliseconds: 800));
    _calculateBalance();
    setState(() {
      _isRefreshing = false;
    });
  }

  void _toggleBalanceVisibility() {
    HapticFeedback.selectionClick();
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  void _deleteTransaction(String transactionId) async {
    final transaction = _transactionBox?.values.firstWhereOrNull((t) => t.id == transactionId);
    if (transaction != null) {
      await transaction.delete();
    _calculateBalance();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction deleted'),
      ),
    );
    }
  }

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 35.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 3.h),
                  _buildBottomSheetAction(
                    'Add Income',
                    'Record money received',
                    'add_circle',
                    AppTheme.getSuccessColor(true),
                    () => Navigator.pushNamed(context, '/add-cash-income'),
                  ),
                  _buildBottomSheetAction(
                    'Record Expense',
                    'Log money spent',
                    'remove_circle',
                    AppTheme.lightTheme.colorScheme.error,
                    () => Navigator.pushNamed(context, '/record-payment'),
                  ),
                  _buildBottomSheetAction(
                    'New Reminder',
                    'Set payment alert',
                    'notifications',
                    AppTheme.getWarningColor(true),
                    () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetAction(String title, String subtitle, String icon,
      Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 12.w,
        height: 6.h,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: color,
            size: 6.w,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Transaction>('transactions').listenable(),
          builder: (context, Box<Transaction> box, _) {
            final transactions = box.values.toList().reversed.toList();
            return Column(
          children: [
            // Tab Bar
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'dashboard',
                      size: 5.w,
                    ),
                    text: 'Dashboard',
                  ),
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'receipt_long',
                      size: 5.w,
                    ),
                    text: 'Transactions',
                  ),
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'notifications',
                      size: 5.w,
                    ),
                    text: 'Reminders',
                  ),
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      size: 5.w,
                    ),
                    text: 'Settings',
                  ),
                ],
                onTap: (index) {
                  switch (index) {
                    case 0:
                      // Already on dashboard
                      break;
                    case 1:
                      Navigator.pushNamed(context, '/transaction-history');
                      break;
                    case 2:
                      Navigator.pushNamed(context, '/settings');
                      break;
                    case 3:
                      Navigator.pushNamed(context, '/settings');
                      break;
                  }
                },
              ),
            ),

            // Dashboard Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshBalance,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Card
                      GestureDetector(
                        onLongPress: _toggleBalanceVisibility,
                        child: BalanceCardWidget(
                          balance: _currentBalance,
                          isVisible: _isBalanceVisible,
                          lastUpdated: _lastUpdated,
                          isRefreshing: _isRefreshing,
                          onRefresh: _refreshBalance,
                        ),
                      ),

                      SizedBox(height: 2.h),

                          // Firm Balances
                          ValueListenableBuilder(
                            valueListenable: Hive.box<Firm>('firms').listenable(),
                            builder: (context, Box<Firm> firmsBox, _) {
                              final firms = firmsBox.values.toList();
                              final firmBalances = _calculateFirmBalances();
                              
                              if (firms.isNotEmpty) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                      child: Text(
                                        'Firm Balances',
                                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Container(
                                      height: 12.h,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                                        itemCount: firms.length,
                                        itemBuilder: (context, index) {
                                          final firm = firms[index];
                                          final balance = firmBalances[firm.id] ?? 0.0;
                                          
                                          return Container(
                                            width: 25.w,
                                            margin: EdgeInsets.only(right: 3.w),
                                            padding: EdgeInsets.all(3.w),
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
                                                Row(
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
                                                    SizedBox(width: 2.w),
                                                    Expanded(
                                                      child: Text(
                                                        firm.name,
                                                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  '₹${balance.toStringAsFixed(2)}',
                                                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                                    color: balance >= 0 
                                                        ? AppTheme.getSuccessColor(true)
                                                        : AppTheme.lightTheme.colorScheme.error,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),

                          SizedBox(height: 1.h),

                      // Quick Actions
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'Quick Actions',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Container(
                        height: 20.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          itemCount: _quickActions.length,
                          itemBuilder: (context, index) {
                            final action = _quickActions[index];
                            return QuickActionCardWidget(
                              title: action["title"] as String,
                              description: action["description"] as String,
                              icon: action["icon"] as String,
                              color: action["color"] as Color,
                              onTap: () => Navigator.pushNamed(
                                  context, action["route"] as String),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Recent Transactions
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: AppTheme.lightTheme.textTheme.titleLarge,
                            ),
                            TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/transaction-history'),
                              child: Text('View All'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),
                          transactions.isEmpty
                          ? EmptyStateWidget()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                                  itemCount: transactions.length > 5 ? 5 : transactions.length,
                              itemBuilder: (context, index) {
                                    final transaction = transactions[index];
                                return RecentTransactionCardWidget(
                                      transaction: {
                                        'id': transaction.id,
                                        'type': transaction.type,
                                        'amount': transaction.amount,
                                        'description': transaction.description,
                                        'source': transaction.source,
                                        'recipient': transaction.recipient,
                                        'date': transaction.date,
                                        'category': transaction.category,
                                        'phone': transaction.phone,
                                      },
                                      onDelete: () => _deleteTransaction(transaction.id),
                                );
                              },
                            ),
                      SizedBox(height: 10.h), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ),
          ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showActionBottomSheet,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor!,
          size: 7.w,
        ),
      ),
    );
  }
}
