import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:collection/collection.dart';

import '../../core/app_export.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/monthly_header_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/transaction_card_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/transaction_model.dart';
import '../../core/firm_model.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedFilter = 'All';
  DateTimeRange? _selectedDateRange;
  double? _minAmount;
  double? _maxAmount;
  String _selectedTransactionType = 'All';
  String? _selectedFirmFilter;
  bool _isLoading = false;

  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  Map<String, List<Transaction>> _groupedTransactions = {};

  final List<String> _filterOptions = ['All', 'Income', 'Expense'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  void _loadTransactions() {
    final box = Hive.box<Transaction>('transactions');
    _allTransactions = box.values.toList();
    _allTransactions.sort((a, b) => b.date.compareTo(a.date));
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTransactions = _allTransactions.where((transaction) {
      bool matchesSearch = transaction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (transaction.recipient?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (transaction.source?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      bool matchesTypeFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Income' && transaction.type == 'income') ||
          (_selectedFilter == 'Expense' && transaction.type == 'expense');
      
      bool matchesFirmFilter = _selectedFirmFilter == null || 
          transaction.firmId == _selectedFirmFilter;
      
      bool matchesDateRange = _selectedDateRange == null ||
          (transaction.date.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
              transaction.date.isBefore(_selectedDateRange!.end.add(Duration(days: 1))));
      
      bool matchesAmount = (_minAmount == null || transaction.amount >= _minAmount!) &&
          (_maxAmount == null || transaction.amount <= _maxAmount!);
      
      return matchesSearch && matchesTypeFilter && matchesFirmFilter && matchesDateRange && matchesAmount;
    }).toList();
    
    _groupTransactionsByMonth();
  }

  String _getFirmName(String firmId) {
    final firm = Hive.box<Firm>('firms').values.firstWhereOrNull((f) => f.id == firmId);
    return firm?.name ?? 'Unknown Firm';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more transactions (if implementing pagination)
    }
  }

  void _groupTransactionsByMonth() {
    Map<String, List<Transaction>> grouped = {};
    for (var transaction in _filteredTransactions) {
      DateTime date = transaction.date;
      String monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }
    _groupedTransactions.clear();
    _groupedTransactions = grouped;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _applyFilters();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedDateRange: _selectedDateRange,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        selectedTransactionType: _selectedTransactionType,
        onApplyFilters: (dateRange, minAmount, maxAmount, transactionType) {
          setState(() {
            _selectedDateRange = dateRange;
            _minAmount = minAmount;
            _maxAmount = maxAmount;
            _selectedTransactionType = transactionType;
            _applyFilters();
          });
        },
        onClearFilters: () {
          setState(() {
            _selectedDateRange = null;
            _minAmount = null;
            _maxAmount = null;
            _selectedTransactionType = 'All';
            _applyFilters();
          });
        },
      ),
    );
  }

  void _onTransactionAction(String action, Transaction transaction) async {
    final box = Hive.box<Transaction>('transactions');
    switch (action) {
      case 'edit':
        // Navigate to edit transaction screen
        break;
      case 'delete':
        await transaction.delete();
        _loadTransactions();
        break;
      case 'duplicate':
        final duplicated = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: transaction.type,
          amount: transaction.amount,
          recipient: transaction.recipient,
          source: transaction.source,
          description: transaction.description,
          date: DateTime.now(),
          category: transaction.category,
          phone: transaction.phone,
          firmId: transaction.firmId,
        );
        await box.add(duplicated);
        _loadTransactions();
        break;
      case 'reminder':
        _setReminder(transaction);
        break;
    }
  }

  void _setReminder(Transaction transaction) {
    // Implement reminder setting logic
  }

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _applyFilters();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: _isSearching
            ? SearchBarWidget(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _toggleSearch,
              )
            : Text(
                'Transaction History',
                style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              onPressed: _toggleSearch,
              icon: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.lightTheme.tabBarTheme.labelColor,
          unselectedLabelColor:
              AppTheme.lightTheme.tabBarTheme.unselectedLabelColor,
          indicatorColor: AppTheme.lightTheme.tabBarTheme.indicatorColor,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Income'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          
          // Transactions list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(),
                _buildTransactionsList(filterType: 'income'),
                _buildTransactionsList(filterType: 'expense'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-cash-income'),
        backgroundColor:
            AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTransactionsList({String? filterType}) {
    List<Transaction> displayTransactions = filterType == null
        ? _filteredTransactions
        : _filteredTransactions.where((t) => t.type == filterType).toList();

    if (displayTransactions.isEmpty) {
      return _buildEmptyState();
    }

    // Group by month for display
    Map<String, List<Transaction>> groupedForDisplay = {};
    for (var transaction in displayTransactions) {
      DateTime date = transaction.date;
      String monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (!groupedForDisplay.containsKey(monthKey)) {
        groupedForDisplay[monthKey] = [];
      }
      groupedForDisplay[monthKey]!.add(transaction);
    }

    List<Widget> widgets = [];
    groupedForDisplay.forEach((monthKey, transactions) {
      DateTime monthDate = DateTime(
          int.parse(monthKey.split('-')[0]), int.parse(monthKey.split('-')[1]));
      double monthTotal = transactions.fold(0.0, (sum, transaction) {
        return sum + (transaction.type == 'income'
            ? transaction.amount
            : -transaction.amount);
      });

      // Add month header
      widgets.add(MonthlyHeaderWidget(
        month: monthDate,
        total: monthTotal,
        transactionCount: transactions.length,
      ));

      // Add transactions
      transactions.sort((a, b) => b.date.compareTo(a.date));
      for (var transaction in transactions) {
        widgets.add(_buildTransactionCard(transaction));
      }
    });

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: widgets.length,
        itemBuilder: (context, index) => widgets[index],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'receipt_long',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'No transactions found'
                : 'No transactions yet',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Start by adding your first transaction',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-cash-income'),
              child: Text('Add Transaction'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Firm>('firms').listenable(),
      builder: (context, Box<Firm> firmsBox, _) {
        final firms = firmsBox.values.toList();
        
        return Container(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                            _applyFilters();
                          });
                        },
                        selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                        checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              if (firms.isNotEmpty) ...[
                SizedBox(height: 1.h),
                // Firm filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text('All Firms'),
                        selected: _selectedFirmFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFirmFilter = null;
                            _applyFilters();
                          });
                        },
                        selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                        checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      ...firms.map((firm) {
                        final isSelected = _selectedFirmFilter == firm.id;
                        return Padding(
                          padding: EdgeInsets.only(left: 2.w),
                          child: FilterChip(
                            label: Text(firm.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFirmFilter = selected ? firm.id : null;
                                _applyFilters();
                              });
                            },
                            selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                            checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    final firmName = _getFirmName(transaction.firmId);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      child: ListTile(
        contentPadding: EdgeInsets.all(4.w),
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? AppTheme.getSuccessColor(true)
              : AppTheme.lightTheme.colorScheme.error,
          child: CustomIconWidget(
            iconName: isIncome ? 'trending_up' : 'trending_down',
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.description,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isIncome
                    ? AppTheme.getSuccessColor(true)
                    : AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0.5.h),
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 16,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 1.w),
                Text(
                  firmName,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Spacer(),
                Text(
                  _formatDate(transaction.date),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (transaction.recipient != null || transaction.source != null) ...[
              SizedBox(height: 0.5.h),
              Text(
                isIncome
                    ? 'From: ${transaction.source ?? 'Unknown'}'
                    : 'To: ${transaction.recipient ?? 'Unknown'}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.category,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicate'),
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
          onSelected: (value) => _onTransactionAction(value, transaction),
        ),
      ),
    );
  }
}
