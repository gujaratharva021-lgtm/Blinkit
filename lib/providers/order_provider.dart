import 'package:flutter/material.dart';
import '../data/repositories/order_repository.dart';
import '../models/order_model.dart';

enum LoadStatus { initial, loading, loaded, error, loadingMore }

class _TabState {
  List<Order> orders = [];
  LoadStatus status = LoadStatus.initial;
  int page = 0;
  bool hasMore = true;
  String? errorMessage;
}

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo = OrderRepository();
  final Map<OrderStatus, _TabState> _tabs = {
    OrderStatus.active: _TabState(),
    OrderStatus.delivered: _TabState(),
    OrderStatus.cancelled: _TabState(),
  };

  List<Order> ordersFor(OrderStatus status) => _tabs[status]!.orders;
  LoadStatus statusFor(OrderStatus status) => _tabs[status]!.status;
  bool hasMoreFor(OrderStatus status) => _tabs[status]!.hasMore;
  String? errorFor(OrderStatus status) => _tabs[status]!.errorMessage;

  Future<void> loadOrders(OrderStatus status, {bool refresh = false}) async {
    final tab = _tabs[status]!;
    if (refresh) {
      tab.page = 0;
      tab.hasMore = true;
      tab.orders = [];
    }
    if (tab.status == LoadStatus.loading || tab.status == LoadStatus.loadingMore) return;

    tab.status = tab.orders.isEmpty ? LoadStatus.loading : LoadStatus.loadingMore;
    tab.errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.fetchOrders(status, page: tab.page);
      tab.orders.addAll(result);
      tab.hasMore = result.length == OrderRepository.pageSize;
      tab.page++;
      tab.status = LoadStatus.loaded;
    } catch (e) {
      tab.status = LoadStatus.error;
      tab.errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> loadMore(OrderStatus status) async {
    final tab = _tabs[status]!;
    if (!tab.hasMore || tab.status == LoadStatus.loadingMore) return;
    await loadOrders(status);
  }

  Future<Order> fetchDetails(String id) => _repo.fetchOrderDetails(id);
}
