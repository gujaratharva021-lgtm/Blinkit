import '../../models/order_model.dart';
import '../../services/api_service.dart';

class OrderRepository {
  static const int pageSize = 6;

  List<Order>? _cache;

  Future<List<Order>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await ApiService.getOrders(page: 1, limit: 100);
    _cache = raw
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return _cache!;
  }

  void invalidate() => _cache = null;

  Future<List<Order>> fetchOrders(OrderStatus status,
      {int page = 0, bool simulateError = false}) async {
    if (simulateError) {
      throw Exception('Unable to load orders. Please check your connection.');
    }
    final all = await _loadAll();
    final filtered = all.where((o) => o.status == status).toList();
    final start = page * pageSize;
    if (start >= filtered.length) return [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  Future<Order> fetchOrderDetails(String id) async {
    final all = await _loadAll();
    return all.firstWhere((o) => o.id == id);
  }
}