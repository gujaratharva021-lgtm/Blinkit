import '../../models/order_model.dart';

class OrderRepository {
  static const int pageSize = 6;

  late final List<Order> _active = _generate(OrderStatus.active, 8);
  late final List<Order> _delivered = _generate(OrderStatus.delivered, 14);
  late final List<Order> _cancelled = _generate(OrderStatus.cancelled, 5);

  static List<Order> _generate(OrderStatus status, int count) {
    return List.generate(count, (i) {
      final id = '${status.name.toUpperCase().substring(0, 3)}${1000 + i}';
      final date = DateTime.now().subtract(Duration(days: i * 2 + 1));
      final items = [
        OrderItem(
            name: 'Amul Belgian Chocolate',
            image: 'assets/images/Ice Creams/Amul Belgian chocolate.png',
            unit: '1 cone',
            quantity: 1,
            price: 120),
        if (i % 2 == 0)
          OrderItem(
              name: 'Apple',
              image: 'assets/images/Fruits/Apple.png',
              unit: '4 pcs',
              quantity: 1,
              price: 120),
      ];
      final itemTotal = items.fold(0, (s, it) => s + it.price * it.quantity);

      List<OrderTimelineStep> timeline;
      switch (status) {
        case OrderStatus.active:
          timeline = [
            OrderTimelineStep(title: 'Order placed', time: 'Today, 10:00 AM', completed: true),
            OrderTimelineStep(title: 'Packed', time: 'Today, 10:05 AM', completed: true),
            OrderTimelineStep(title: 'Out for delivery', time: null, completed: false),
            OrderTimelineStep(title: 'Delivered', time: null, completed: false),
          ];
          break;
        case OrderStatus.delivered:
          timeline = [
            OrderTimelineStep(title: 'Order placed', time: 'Placed', completed: true),
            OrderTimelineStep(title: 'Packed', time: 'Packed', completed: true),
            OrderTimelineStep(title: 'Out for delivery', time: 'Dispatched', completed: true),
            OrderTimelineStep(title: 'Delivered', time: 'Delivered', completed: true),
          ];
          break;
        case OrderStatus.cancelled:
          timeline = [
            OrderTimelineStep(title: 'Order placed', time: 'Placed', completed: true),
            OrderTimelineStep(title: 'Cancelled', time: 'Cancelled', completed: true),
          ];
          break;
      }

      return Order(
        id: id,
        date: date,
        items: items,
        status: status,
        address: 'Home - 221B, Green Residency, Mumbai, Maharashtra',
        paymentMethod: i % 3 == 0 ? 'UPI' : 'Cash on Delivery',
        itemTotal: itemTotal,
        deliveryFee: 25,
        platformFee: 5,
        discount: i % 4 == 0 ? 20 : 0,
        timeline: timeline,
      );
    });
  }

  List<Order> _listFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return _active;
      case OrderStatus.delivered:
        return _delivered;
      case OrderStatus.cancelled:
        return _cancelled;
    }
  }

  Future<List<Order>> fetchOrders(OrderStatus status,
      {int page = 0, bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (simulateError) {
      throw Exception('Unable to load orders. Please check your connection.');
    }
    final list = _listFor(status);
    final start = page * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  Future<Order> fetchOrderDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final all = [..._active, ..._delivered, ..._cancelled];
    return all.firstWhere((o) => o.id == id);
  }
}
