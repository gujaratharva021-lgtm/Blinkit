import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final int price;
  final String unit;
  final String image;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.unit,
    required this.image,
    this.quantity = 1,
  });
}

class Order {
  final String orderId;
  final String date;
  final List<CartItem> items;
  final int totalAmount;
  String status;

  Order({
    required this.orderId,
    required this.date,
    required this.items,
    required this.totalAmount,
    this.status = 'Delivered',
  });
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _cartItems = {};
  final List<Order> _orders = [];

  // Cart Getters
  Map<String, CartItem> get cartItems => _cartItems;

  int get cartCount => _cartItems.values
      .fold(0, (sum, item) => sum + item.quantity);

  int get cartTotal => _cartItems.values
      .fold(0, (sum, item) => sum + (item.price * item.quantity));

  List<Order> get orders => _orders;

  // Add to Cart
  void addToCart(String name, int price, String unit, String image) {
    if (_cartItems.containsKey(name)) {
      _cartItems[name]!.quantity++;
    } else {
      _cartItems[name] = CartItem(
        name: name,
        price: price,
        unit: unit,
        image: image,
      );
    }
    notifyListeners();
  }

  // Remove from Cart
  void removeFromCart(String name) {
    if (_cartItems.containsKey(name)) {
      if (_cartItems[name]!.quantity > 1) {
        _cartItems[name]!.quantity--;
      } else {
        _cartItems.remove(name);
      }
    }
    notifyListeners();
  }

  // Get Quantity
  int getQuantity(String name) {
    return _cartItems[name]?.quantity ?? 0;
  }

  // Place Order
  void placeOrder() {
    if (_cartItems.isEmpty) return;

    final order = Order(
      orderId: 'MPT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: _formatDate(),
      items: _cartItems.values.toList(),
      totalAmount: cartTotal + 30,
    );

    _orders.insert(0, order);
    _cartItems.clear();
    notifyListeners();
  }

  // Clear Cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  String _formatDate() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:$min $ampm';
  }
}