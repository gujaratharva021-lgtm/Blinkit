import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> _items = [];
  int _totalItems = 0;
  double _totalAmount = 0;
  bool _isLoading = false;

  List<dynamic> get items => _items;
  bool get isLoading => _isLoading;

  int get cartCount => _totalItems;

  double get cartTotal => _totalAmount;

  // The phantom local-only cart (items that were never sent to the server)
  // has been removed. This getter is kept so existing screens that render
  // "local" items keep compiling; it now always returns an empty list since
  // every cart item is server-backed.
  List<Map<String, dynamic>> get localCartItems => const [];

  int? getCartItemId(int productId) {
    for (final item in _items) {
      if (item['product_id'] == productId) return item['id'];
    }
    return null;
  }

  int getQuantityByProductId(dynamic productId) {
    final int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);
    if (realId == null) return 0;
    for (final item in _items) {
      if (item['product_id'] == realId) return item['quantity'];
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

  Future<void> addProduct(dynamic productId,
      {int quantity = 1, Map<String, dynamic>? productData}) async {
    final int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);

    if (realId == null || realId <= 0) {
      throw Exception('This product cannot be added to the cart right now (invalid product id).');
    }
    try {
      final data = await ApiService.addToCart(realId, quantity);
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('addProduct error: $e');
      throw Exception('Could not add item to cart. Please try again.');
    }
  }

  Future<void> increment(dynamic productId, {Map<String, dynamic>? productData}) async {
    await addProduct(productId, quantity: 1, productData: productData);
  }

  Future<void> decrement(dynamic productId) async {
    final int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);
    if (realId == null) return;

    final itemId = getCartItemId(realId);
    if (itemId == null) return;
    final currentQty = getQuantityByProductId(realId);
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
      throw Exception('Could not update cart. Please try again.');
    }
  }

  Future<void> removeItemByProductId(dynamic productId) async {
    final int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);
    if (realId == null) return;

    final itemId = getCartItemId(realId);
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
