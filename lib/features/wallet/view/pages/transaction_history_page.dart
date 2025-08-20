import 'package:fieldforce/features/wallet/provider/wallet_provider.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends ConsumerState<TransactionHistoryPage> {
  String _selectedFilter = 'all';
  String _selectedPeriod = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Simple date formatting function to replace DateFormat
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    List<TransactionModel> filtered = transactions;

    // Filter by type
    if (_selectedFilter != 'all') {
      filtered = filtered.where((transaction) {
        return transaction.type.value == _selectedFilter;
      }).toList();
    }

    // Filter by period
    if (_selectedPeriod != 'all') {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(2000); // Very old date for 'all'
      }
      
      filtered = filtered.where((transaction) {
        return transaction.createdAt.isAfter(startDate);
      }).toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.description.toLowerCase().contains(query) ||
               transaction.type.value.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(getUserTransactionsProvider);

    return Scaffold(
      backgroundColor: Colours.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colours.backgroundColor,
        elevation: 0,
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: Colours.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Symbols.arrow_back,
            color: Colours.whiteColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.refresh(getUserTransactionsProvider);
            },
            icon: const Icon(
              Symbols.refresh,
              color: Colours.whiteColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colours.whiteColor),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    hintStyle: TextStyle(
                      color: Colours.whiteColor.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(
                      Symbols.search,
                      color: kPrimary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colours.whiteColor.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colours.whiteColor.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: kPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Trigger rebuild to apply search filter
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Filter Chips
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All Types', 'all', _selectedFilter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Earnings', 'earning', _selectedFilter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Withdrawals', 'withdrawal', _selectedFilter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Commissions', 'commission', _selectedFilter),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Period Filter
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPeriodChip('All Time', 'all'),
                            const SizedBox(width: 8),
                            _buildPeriodChip('Today', 'today'),
                            const SizedBox(width: 8),
                            _buildPeriodChip('This Week', 'week'),
                            const SizedBox(width: 8),
                            _buildPeriodChip('This Month', 'month'),
                            const SizedBox(width: 8),
                            _buildPeriodChip('This Year', 'year'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Transaction List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filteredTransactions = _filterTransactions(transactions);
                
                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.receipt_long,
                          size: 64,
                          color: Colours.whiteColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: Colours.whiteColor.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or search terms',
                          style: TextStyle(
                            color: Colours.whiteColor.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(getUserTransactionsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: kPrimary),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.error,
                      size: 64,
                      color: Colours.errorColor.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading transactions',
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.7),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(getUserTransactionsProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue) {
    final isSelected = selectedValue == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colours.whiteColor.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colours.cardColor,
      selectedColor: kPrimary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? kPrimary : Colours.whiteColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colours.whiteColor.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = value;
        });
      },
      backgroundColor: Colours.cardColor,
      selectedColor: kPrimary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? kPrimary : Colours.whiteColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isPositive = transaction.type == TransactionType.earning || 
                      transaction.type == TransactionType.commission;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = _getTransactionIcon(transaction.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colours.whiteColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    color: Colours.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction.type.value.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(transaction.createdAt),
                style: TextStyle(
                  color: Colours.whiteColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return Symbols.trending_up;
      case TransactionType.withdrawal:
        return Symbols.trending_down;
      case TransactionType.commission:
        return Symbols.payments;
      case TransactionType.refund:
        return Symbols.undo;
      default:
        return Symbols.receipt;
    }
  }
}