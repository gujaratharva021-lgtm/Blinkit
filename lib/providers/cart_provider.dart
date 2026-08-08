import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> _items = [];
  int _totalItems = 0;
  double _totalAmount = 0;
  bool _isLoading = false;

  final Map<String, int> _localQuantities = {};
  final Map<String, Map<String, dynamic>> _localProductData = {};

  List<dynamic> get items => _items;
  bool get isLoading => _isLoading;

  int get cartCount =>
      _totalItems + _localQuantities.values.fold(0, (a, b) => a + b);

  double get cartTotal {
    double localTotal = 0;
    _localQuantities.forEach((id, qty) {
      final price = (_localProductData[id]?['price'] as num?)?.toDouble() ?? 0;
      localTotal += price * qty;
    });
    return _totalAmount + localTotal;
  }

  List<Map<String, dynamic>> get localCartItems {
    return _localQuantities.entries.map((e) {
      final data = _localProductData[e.key] ?? {};
      return {
        'id': e.key,
        'name': data['name'] ?? '',
        'brand': data['brand'] ?? '',
        'weight': data['weight'] ?? '',
        'price': data['price'] ?? 0,
        'image': data['image'],
        'quantity': e.value,
      };
    }).toList();
  }

  int? getCartItemId(int productId) {
    for (final item in _items) {
      if (item['product_id'] == productId) return item['id'];
    }
    return null;
  }

  int getQuantityByProductId(dynamic productId) {
    int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);
    if (realId == null) {
      return _localQuantities[productId.toString()] ?? 0;
    }
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
    int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);

    if (realId == null) {
      final key = productId.toString();
      if (productData != null) {
        _localProductData[key] = productData;
      }
      _localQuantities[key] = (_localQuantities[key] ?? 0) + quantity;
      notifyListeners();
      return;
    }
    if (realId <= 0) {
      throw Exception('Yeh product abhi cart mein add nahi ho sakta (invalid product id).');
    }
    try {
      debugPrint('addProduct >>> calling API for id=$realId');
      final data = await ApiService.addToCart(realId, quantity);
      debugPrint('addProduct >>> SUCCESS response=$data');
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('addProduct >>> ERROR: $e');
      throw Exception('Add to cart fail hua: $e');
    }
  }

  Future<void> increment(dynamic productId, {Map<String, dynamic>? productData}) async {
    await addProduct(productId, quantity: 1, productData: productData);
  }

  Future<void> decrement(dynamic productId) async {
    int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);

    if (realId == null) {
      final key = productId.toString();
      final current = _localQuantities[key] ?? 0;
      if (current <= 1) {
        _localQuantities.remove(key);
        _localProductData.remove(key);
      } else {
        _localQuantities[key] = current - 1;
      }
      notifyListeners();
      return;
    }
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
      throw Exception('Update fail hua: $e');
    }
  }

  Future<void> removeItemByProductId(dynamic productId) async {
    int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);

    if (realId == null) {
      final key = productId.toString();
      _localQuantities.remove(key);
      _localProductData.remove(key);
      notifyListeners();
      return;
    }
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
    _localQuantities.clear();
    _localProductData.clear();
    notifyListeners();
  }
}
