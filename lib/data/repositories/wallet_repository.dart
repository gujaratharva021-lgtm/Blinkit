import '../../models/wallet_model.dart';

class WalletRepository {
  static const int pageSize = 6;

  late final List<WalletTransaction> _all = List.generate(20, (i) {
    final types = TransactionType.values;
    final type = types[i % types.length];
    String desc;
    switch (type) {
      case TransactionType.cashback:
        desc = 'Cashback on order #GF${1000 + i}';
        break;
      case TransactionType.refund:
        desc = 'Refund for order #GF${1000 + i}';
        break;
      case TransactionType.debit:
        desc = 'Used for order #GF${1000 + i}';
        break;
      case TransactionType.credit:
        desc = 'Added to wallet';
        break;
    }
    return WalletTransaction(
      id: 'TXN${2000 + i}',
      amount: 20 + (i * 7) % 200,
      date: DateTime.now().subtract(Duration(days: i)),
      status: i % 5 == 0 ? TransactionStatus.pending : TransactionStatus.success,
      type: type,
      description: desc,
    );
  });

  Future<WalletSummary> fetchSummary({bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (simulateError) throw Exception('Unable to load wallet summary');
    final cashback = _all
        .where((t) => t.type == TransactionType.cashback)
        .fold(0, (s, t) => s + t.amount);
    return WalletSummary(
        currentBalance: 250, cashbackEarned: cashback, totalSavings: cashback + 180);
  }

  Future<List<WalletTransaction>> fetchTransactions(TransactionType? filterType,
      {int page = 0, bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (simulateError) throw Exception('Unable to load transactions');
    final filtered =
        filterType == null ? _all : _all.where((t) => t.type == filterType).toList();
    final start = page * pageSize;
    if (start >= filtered.length) return [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }
}
