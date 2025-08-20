import 'package:fieldforce/features/wallet/provider/wallet_provider.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class WithdrawalRequestsPage extends ConsumerStatefulWidget {
  const WithdrawalRequestsPage({super.key});

  @override
  ConsumerState<WithdrawalRequestsPage> createState() => _WithdrawalRequestsPageState();
}

class _WithdrawalRequestsPageState extends ConsumerState<WithdrawalRequestsPage> {
  String _selectedStatus = 'all';

  // Simple date formatting function to replace DateFormat
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  List<WithdrawalRequestModel> _filterRequests(List<WithdrawalRequestModel> requests) {
    if (_selectedStatus == 'all') {
      return requests;
    }
    
    return requests.where((request) {
      return request.status.value == _selectedStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalRequestsAsync = ref.watch(getUserWithdrawalRequestsProvider);

    return Scaffold(
      backgroundColor: Colours.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colours.backgroundColor,
        elevation: 0,
        title: const Text(
          'Withdrawal Requests',
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
              ref.refresh(getUserWithdrawalRequestsProvider);
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
          // Status Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Processing', 'processing'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Cancelled', 'cancelled'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Failed', 'failed'),
                ],
              ),
            ),
          ),
          
          // Withdrawal Requests List
          Expanded(
            child: withdrawalRequestsAsync.when(
              data: (requests) {
                final filteredRequests = _filterRequests(requests);
                
                if (filteredRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.account_balance_wallet,
                          size: 64,
                          color: Colours.whiteColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No withdrawal requests found',
                          style: TextStyle(
                            color: Colours.whiteColor.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedStatus == 'all' 
                              ? 'You haven\'t made any withdrawal requests yet'
                              : 'No requests with $_selectedStatus status',
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
                    ref.refresh(getUserWithdrawalRequestsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return _buildWithdrawalRequestCard(request);
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
                      'Error loading withdrawal requests',
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
                        ref.refresh(getUserWithdrawalRequestsProvider);
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

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedStatus == value;
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
          _selectedStatus = value;
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

  Widget _buildWithdrawalRequestCard(WithdrawalRequestModel request) {
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Withdrawal Request',
                      style: TextStyle(
                        color: Colours.whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${request.id.substring(0, 8)}...',
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.status.value.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Amount and Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${request.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colours.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Processing Fee',
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\${(request.processingFee ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colours.whiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Amount',
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\${request.calculatedNetAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bank Account Info
          if (request.bankAccountId.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colours.backgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Symbols.account_balance,
                    color: kPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bank Account: ${request.bankAccountId.substring(0, 8)}...',
                    style: TextStyle(
                      color: Colours.whiteColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Dates
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested',
                      style: TextStyle(
                        color: Colours.whiteColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(request.requestedAt),
                      style: const TextStyle(
                        color: Colours.whiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (request.processedAt != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Processed',
                        style: TextStyle(
                          color: Colours.whiteColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(request.processedAt!),
                        style: const TextStyle(
                          color: Colours.whiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          // Notes
          if (request.notes != null && request.notes!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Notes',
                  style: TextStyle(
                    color: Colours.whiteColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.notes!,
                  style: const TextStyle(
                    color: Colours.whiteColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          
          // Cancel Button (if cancellable)
          if (request.canBeCancelled)
            Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(request),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel Request',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return Colors.orange;
      case WithdrawalStatus.processing:
        return Colors.blue;
      case WithdrawalStatus.completed:
        return Colors.green;
      case WithdrawalStatus.cancelled:
        return Colors.grey;
      case WithdrawalStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return Symbols.schedule;
      case WithdrawalStatus.processing:
        return Symbols.sync;
      case WithdrawalStatus.completed:
        return Symbols.check_circle;
      case WithdrawalStatus.cancelled:
        return Symbols.cancel;
      case WithdrawalStatus.failed:
        return Symbols.error;
      default:
        return Symbols.help;
    }
  }

  void _showCancelDialog(WithdrawalRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colours.cardColor,
        title: const Text(
          'Cancel Withdrawal Request',
          style: TextStyle(color: Colours.whiteColor),
        ),
        content: Text(
          'Are you sure you want to cancel this withdrawal request for \$${request.amount.toStringAsFixed(2)}?',
          style: TextStyle(
            color: Colours.whiteColor.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Request'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(walletControllerProvider.notifier)
                    .cancelWithdrawalRequest(request.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Withdrawal request cancelled'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error cancelling request: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }
}