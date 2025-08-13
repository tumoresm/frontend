/// Enums for wallet-related functionality

/// Types of transactions in the wallet system
enum TransactionType {
  earning,      // Money earned from orders/commissions
  payment,      // Payment received to bank account
  withdrawal,   // Money withdrawn from wallet
  commission,   // Commission earned from sales
  bonus,        // Bonus payments
  refund,       // Refunded amounts
}

/// Status of transactions and withdrawal requests
enum TransactionStatus {
  pending,      // Transaction is pending processing
  processing,   // Transaction is being processed
  completed,    // Transaction completed successfully
  failed,       // Transaction failed
  cancelled,    // Transaction was cancelled
}

/// Status of withdrawal requests
enum WithdrawalStatus {
  pending,      // Withdrawal request submitted, awaiting approval
  approved,     // Withdrawal approved, processing payment
  processing,   // Payment is being processed
  completed,    // Withdrawal completed successfully
  failed,       // Withdrawal failed
  cancelled,    // Withdrawal was cancelled
  rejected,     // Withdrawal was rejected
}

/// Extension methods for enum string conversion
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.earning:
        return 'Earning';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.commission:
        return 'Commission';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.refund:
        return 'Refund';
    }
  }

  String get value => toString().split('.').last;
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get value => toString().split('.').last;
}

extension WithdrawalStatusExtension on WithdrawalStatus {
  String get displayName {
    switch (this) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.approved:
        return 'Approved';
      case WithdrawalStatus.processing:
        return 'Processing';
      case WithdrawalStatus.completed:
        return 'Completed';
      case WithdrawalStatus.failed:
        return 'Failed';
      case WithdrawalStatus.cancelled:
        return 'Cancelled';
      case WithdrawalStatus.rejected:
        return 'Rejected';
    }
  }

  String get value => toString().split('.').last;
}