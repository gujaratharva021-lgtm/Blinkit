import '../../../services/api_service.dart';
import '../data/category_mock_data.dart';
import '../models/category_models.dart';

/// Products/categories now come from the real backend where available.
/// Category/section navigation structure stays mock (pure UI taxonomy),
/// but actual product listings are fetched from ApiService and matched
/// to a mock category by name, so cart/checkout works end-to-end.
class CategoryRepository {
  static List<Map<String, dynamic>>? _cachedProducts;

  Future<List<Map<String, dynamic>>> _allBackendProducts() async {
    if (_cachedProducts != null) return _cachedProducts!;
    try {
      final raw = await ApiService.getProducts();
      _cachedProducts = raw.cast<Map<String, dynamic>>();
    } catch (_) {
      _cachedProducts = [];
    }
    return _cachedProducts!;
  }

  Future<List<CategorySectionModel>> fetchHomeSections() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return CategoryMockData.sections;
  }

  Future<List<SubCategoryModel>> fetchSubCategories(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final category = CategoryMockData.sections
        .expand((s) => s.categories)
        .firstWhere((c) => c.id == categoryId);
    return category.subCategories;
  }

  CategoryModel _findCategoryById(String categoryId) {
    return CategoryMockData.sections
        .expand((s) => s.categories)
        .firstWhere((c) => c.id == categoryId);
  }

  String _categoryName(Map<String, dynamic> raw) {
    final cat = raw['category'];
    if (cat is Map) return (cat['name'] ?? '').toString();
    return '';
  }

  ProductModel _fromBackend(Map<String, dynamic> raw, CategoryModel category) {
    final price = (raw['price'] is num) ? (raw['price'] as num).toDouble() : 0.0;
    final imgUrl = (raw['image_url'] ?? '').toString();
    return ProductModel(
      id: raw['id'].toString(),
      name: (raw['name'] ?? '').toString(),
      brand: '',
      weight: '1 pc',
      price: price,
      mrp: price,
      rating: 4.2,
      ratingCount: 0,
      icon: category.icon,
      color: category.color,
      categoryId: category.id,
      subCategoryId: '',
      description: (raw['description'] ?? '').toString(),
      nutrition: const [],
      deliveryTime: '10 mins',
      inStock: true,
      image: imgUrl.isEmpty ? null : imgUrl,
    );
  }

  Future<List<ProductModel>> fetchProducts({required String categoryId}) async {
    final category = _findCategoryById(categoryId);
    final all = await _allBackendProducts();
    final matched = all
        .where((p) => _categoryName(p).toLowerCase() == category.title.toLowerCase())
        .map((p) => _fromBackend(p, category))
        .toList();
    if (matched.isNotEmpty) return matched;
    // Fallback to mock data only if backend truly has nothing for this category.
    return CategoryMockData.productsForCategory(categoryId);
  }

  Future<ProductModel> fetchProductById(String productId) async {
    final intId = int.tryParse(productId);
    if (intId != null) {
      final all = await _allBackendProducts();
      final match = all.where((p) => p['id'] == intId).toList();
      if (match.isNotEmpty) {
        final raw = match.first;
        final catName = _categoryName(raw);
        final category = CategoryMockData.sections
            .expand((s) => s.categories)
            .firstWhere(
              (c) => c.title.toLowerCase() == catName.toLowerCase(),
              orElse: () => CategoryMockData.sections.first.categories.first,
            );
        return _fromBackend(raw, category);
      }
    }
    return CategoryMockData.allProducts.firstWhere((p) => p.id == productId);
  }

  Future<List<ProductModel>> fetchSimilarProducts(ProductModel product) async {
    final intId = int.tryParse(product.id);
    if (intId != null) {
      final category = _findCategoryById(product.categoryId);
      final all = await _allBackendProducts();
      final matched = all
          .where((p) =>
              _categoryName(p).toLowerCase() == category.title.toLowerCase() &&
              p['id'] != intId)
          .map((p) => _fromBackend(p, category))
          .take(10)
          .toList();
      if (matched.isNotEmpty) return matched;
    }
    return CategoryMockData.allProducts
        .where((p) => p.categoryId == product.categoryId && p.id != product.id)
        .take(10)
        .toList();
  }
}
