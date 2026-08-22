import 'package:flutter/material.dart';
import '../data/repositories/wallet_repository.dart';
import '../models/wallet_model.dart';

enum LoadStatus { initial, loading, loaded, error, loadingMore }
enum WalletTab { transactions, cashback, refunds }

class _TabState {
  List<WalletTransaction> items = [];
  LoadStatus status = LoadStatus.initial;
  int page = 0;
  bool hasMore = true;
  String? error;
}

class WalletProvider extends ChangeNotifier {
  final WalletRepository _repo = WalletRepository();

  WalletSummary? summary;
  LoadStatus summaryStatus = LoadStatus.initial;
  String? summaryError;

  final Map<WalletTab, _TabState> _tabs = {
    WalletTab.transactions: _TabState(),
    WalletTab.cashback: _TabState(),
    WalletTab.refunds: _TabState(),
  };

  TransactionType? _typeFor(WalletTab tab) {
    switch (tab) {
      case WalletTab.transactions:
        return null;
      case WalletTab.cashback:
        return TransactionType.cashback;
      case WalletTab.refunds:
        return TransactionType.refund;
    }
  }

  List<WalletTransaction> itemsFor(WalletTab tab) => _tabs[tab]!.items;
  LoadStatus statusFor(WalletTab tab) => _tabs[tab]!.status;
  bool hasMoreFor(WalletTab tab) => _tabs[tab]!.hasMore;
  String? errorFor(WalletTab tab) => _tabs[tab]!.error;

  Future<void> loadSummary({bool refresh = false}) async {
    if (summaryStatus == LoadStatus.loading && !refresh) return;
    summaryStatus = LoadStatus.loading;
    notifyListeners();
    try {
      summary = await _repo.fetchSummary();
      summaryStatus = LoadStatus.loaded;
    } catch (e) {
      summaryStatus = LoadStatus.error;
      summaryError = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> loadTransactions(WalletTab tab, {bool refresh = false}) async {
    final t = _tabs[tab]!;
    if (refresh) {
      t.page = 0;
      t.hasMore = true;
      t.items = [];
    }
    if (t.status == LoadStatus.loading || t.status == LoadStatus.loadingMore) return;
    t.status = t.items.isEmpty ? LoadStatus.loading : LoadStatus.loadingMore;
    notifyListeners();
    try {
      final result = await _repo.fetchTransactions(_typeFor(tab), page: t.page);
      t.items.addAll(result);
      t.hasMore = result.length == WalletRepository.pageSize;
      t.page++;
      t.status = LoadStatus.loaded;
    } catch (e) {
      t.status = LoadStatus.error;
      t.error = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> loadMore(WalletTab tab) async {
    if (!_tabs[tab]!.hasMore) return;
    await loadTransactions(tab);
  }
}
