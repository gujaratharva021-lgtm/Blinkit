enum TransactionType { cashback, refund, debit, credit }
enum TransactionStatus { success, pending, failed }

class WalletTransaction {
  final String id;
  final int amount;
  final DateTime date;
  final TransactionStatus status;
  final TransactionType type;
  final String description;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.type,
    required this.description,
  });
}

class WalletSummary {
  final int currentBalance;
  final int cashbackEarned;
  final int totalSavings;

  WalletSummary({
    required this.currentBalance,
    required this.cashbackEarned,
    required this.totalSavings,
  });
}
