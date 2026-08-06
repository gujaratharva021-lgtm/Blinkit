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

  /// Finds which subcategory (by position, 0-based) a backend product
  /// belongs to, by checking if any word from a subcategory's title
  /// appears in the product name (e.g. "Farm Eggs (6 pcs)" -> the
  /// "Eggs" subcategory). Falls back to spreading products evenly by
  /// [index] so every tab has something to show even without a match.
  int _guessSubCategoryIndex(String productName, CategoryModel category, int index) {
    final subs = category.subCategories;
    if (subs.isEmpty) return 0;
    final nameLower = productName.toLowerCase();
    for (var s = 0; s < subs.length; s++) {
      final words = subs[s]
          .title
          .toLowerCase()
          .split(RegExp(r'[ &,]+'))
          .where((w) => w.length > 2);
      for (final word in words) {
        if (nameLower.contains(word)) return s;
      }
    }
    return index % subs.length;
  }

  ProductModel _fromBackend(Map<String, dynamic> raw, CategoryModel category, int index) {
    final price = (raw['price'] is num) ? (raw['price'] as num).toDouble() : 0.0;
    final imgUrl = (raw['image_url'] ?? '').toString();
    final name = (raw['name'] ?? '').toString();
    final subIndex = _guessSubCategoryIndex(name, category, index);
    final subs = category.subCategories;
    final subCategoryId = subs.isEmpty ? '' : subs[subIndex].id;
    // Pick an image from the same 3-slot block as the matched subcategory
    // (pool is laid out in blocks of 3 per subcategory, in subcategory
    // order), so e.g. an "Eggs" product gets an egg photo, not whichever
    // image happens to sit at the product's raw list position.
    final poolIndex = subIndex * 3 + (index % 3);
    final fallbackImage = imgUrl.isEmpty
        ? CategoryMockData.imageForCategory(category.id, poolIndex)
        : null;
    return ProductModel(
      id: raw['id'].toString(),
      name: name,
      brand: '',
      weight: '1 pc',
      price: price,
      mrp: price,
      rating: 4.2,
      ratingCount: 0,
      icon: category.icon,
      color: category.color,
      categoryId: category.id,
      subCategoryId: subCategoryId,
      description: (raw['description'] ?? '').toString(),
      nutrition: const [],
      deliveryTime: '10 mins',
      inStock: true,
      image: imgUrl.isEmpty ? fallbackImage : imgUrl,
    );
  }

  Future<List<ProductModel>> fetchProducts({required String categoryId}) async {
    final category = _findCategoryById(categoryId);
    final all = await _allBackendProducts();
    final filtered = all
        .where((p) => _categoryName(p).toLowerCase() == category.title.toLowerCase())
        .toList();
    if (filtered.isEmpty) {
      // No backend products at all for this category yet -> show mock data.
      return CategoryMockData.productsForCategory(categoryId);
    }

    final subs = category.subCategories;
    final bucketCount = subs.isEmpty ? 1 : subs.length;
    final buckets = List.generate(bucketCount, (_) => <ProductModel>[]);
    for (var i = 0; i < filtered.length; i++) {
      final name = (filtered[i]['name'] ?? '').toString();
      final subIndex = subs.isEmpty ? 0 : _guessSubCategoryIndex(name, category, i);
      buckets[subIndex].add(_fromBackend(filtered[i], category, i));
    }

    // Mock data is generated in chunks of 3 per subcategory, in the same
    // order as category.subCategories, so slice it the same way to pad
    // out any subcategory the backend doesn't have 3 items for yet.
    final mockAll = CategoryMockData.productsForCategory(categoryId);
    final result = <ProductModel>[];
    for (var s = 0; s < bucketCount; s++) {
      final backendItems = buckets[s];
      result.addAll(backendItems);
      final need = 3 - backendItems.length;
      if (need > 0) {
        final backendNames = backendItems.map((p) => p.name.toLowerCase()).toSet();
        final fillers = mockAll
            .skip(s * 3)
            .take(3)
            .where((p) => !backendNames.contains(p.name.toLowerCase()))
            .take(need);
        result.addAll(fillers);
      }
    }
    return result;
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
        return _fromBackend(raw, category, 0);
      }
    }
    return CategoryMockData.allProducts.firstWhere((p) => p.id == productId);
  }

  Future<List<ProductModel>> fetchSimilarProducts(ProductModel product) async {
    final intId = int.tryParse(product.id);
    if (intId != null) {
      final category = _findCategoryById(product.categoryId);
      final all = await _allBackendProducts();
      final filtered = all
          .where((p) =>
              _categoryName(p).toLowerCase() == category.title.toLowerCase() &&
              p['id'] != intId)
          .toList();
      final matched = <ProductModel>[
        for (var i = 0; i < filtered.length && i < 10; i++)
          _fromBackend(filtered[i], category, i),
      ];
      if (matched.isNotEmpty) return matched;
    }
    return CategoryMockData.allProducts
        .where((p) => p.categoryId == product.categoryId && p.id != product.id)
        .take(10)
        .toList();
  }
}
