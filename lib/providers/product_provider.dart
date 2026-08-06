import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../features/category_nav/data/category_mock_data.dart';

class ProductProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  Map<String, List<Map<String, dynamic>>> _productsByCategory = {};
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get products => _products;
  Map<String, List<Map<String, dynamic>>> get productsByCategory => _productsByCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static String get _imageHost => ApiService.baseUrl.replaceAll('/api/v1', '');

  String _resolveImage(dynamic imageUrl) {
    final url = (imageUrl ?? '').toString();
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '$_imageHost$url';
  }

  Map<String, dynamic> _toDisplayMap(Map<String, dynamic> raw) {
    final categoryData = raw['category'];
    final categoryName = (categoryData is Map && categoryData['name'] != null)
        ? categoryData['name'].toString()
        : 'Others';
    final name = (raw['name'] ?? '').toString();
    final resolvedImage = _resolveImage(raw['image_url']);
    final id = raw['id'];
    final image = resolvedImage.isNotEmpty
        ? resolvedImage
        : (CategoryMockData.imageForProductByCategoryTitle(
                categoryName, name, id is int ? id : 0) ??
            '');
    return {
      'id': raw['id'],
      'name': name,
      'price': (raw['price'] is num) ? (raw['price'] as num).round() : 0,
      'unit': (raw['description'] ?? '1 pc').toString(),
      'category': categoryName,
      'image': image,
    };
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await ApiService.getProducts();
      final mapped = raw.map((p) => _toDisplayMap(p as Map<String, dynamic>)).toList();

      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final p in mapped) {
        final cat = p['category'] as String;
        grouped.putIfAbsent(cat, () => []).add(p);
      }

      _products = mapped;
      _productsByCategory = grouped;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
