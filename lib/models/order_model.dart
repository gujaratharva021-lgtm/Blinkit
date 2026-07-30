enum OrderStatus { active, delivered, cancelled }

class OrderItem {
  final String name;
  final String image;
  final String unit;
  final int quantity;
  final int price;

  OrderItem({
    required this.name,
    required this.image,
    required this.unit,
    required this.quantity,
    required this.price,
  });
}

class OrderTimelineStep {
  final String title;
  final String? time;
  final bool completed;

  OrderTimelineStep({required this.title, this.time, required this.completed});
}

class Order {
  final String id;
  final DateTime date;
  final List<OrderItem> items;
  final OrderStatus status;
  final String address;
  final String paymentMethod;
  final int itemTotal;
  final int deliveryFee;
  final int platformFee;
  final int discount;
  final List<OrderTimelineStep> timeline;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.itemTotal,
    required this.deliveryFee,
    required this.platformFee,
    this.discount = 0,
    required this.timeline,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  int get grandTotal => itemTotal + deliveryFee + platformFee - discount;

  String get statusLabel {
    switch (status) {
      case OrderStatus.active:
        return 'Order Placed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
