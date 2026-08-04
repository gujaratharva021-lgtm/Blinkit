import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> _items = [];
  int _totalItems = 0;
  double _totalAmount = 0;
  bool _isLoading = false;

  List<dynamic> get items => _items;
  int get cartCount => _totalItems;
  double get cartTotal => _totalAmount;
  bool get isLoading => _isLoading;

  int? getCartItemId(int productId) {
    for (final item in _items) {
      if (item['product_id'] == productId) return item['id'];
    }
    return null;
  }

  int getQuantityByProductId(int productId) {
    for (final item in _items) {
      if (item['product_id'] == productId) return item['quantity'];
    }
    return 0;
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getCart();
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
    } catch (e) {
      debugPrint('loadCart error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(int productId, {int quantity = 1}) async {
    try {
      final data = await ApiService.addToCart(productId, quantity);
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('addProduct error: $e');
    }
  }

  Future<void> increment(int productId) async {
    await addProduct(productId, quantity: 1);
  }

  Future<void> decrement(int productId) async {
    final itemId = getCartItemId(productId);
    if (itemId == null) return;
    final currentQty = getQuantityByProductId(productId);
    try {
      Map<String, dynamic> data;
      if (currentQty <= 1) {
        data = await ApiService.removeCartItem(itemId);
      } else {
        data = await ApiService.updateCartItem(itemId, currentQty - 1);
      }
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('decrement error: $e');
    }
  }

  Future<void> removeItemByProductId(int productId) async {
    final itemId = getCartItemId(productId);
    if (itemId == null) return;
    try {
      final data = await ApiService.removeCartItem(itemId);
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('removeItemByProductId error: $e');
    }
  }

  void clearCartLocal() {
    _items = [];
    _totalItems = 0;
    _totalAmount = 0;
    notifyListeners();
  }
}
