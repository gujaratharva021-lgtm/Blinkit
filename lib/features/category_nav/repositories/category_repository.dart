import '../../../services/api_service.dart';
import '../data/category_mock_data.dart';
import '../models/category_models.dart';

/// Products/categories now come from the real backend where available.
/// Category/section navigation structure stays mock (pure UI taxonomy),
/// but actual product listings are fetched from ApiService and matched
/// to a mock category by name, so cart/checkout works end-to-end.
class CategoryRepository {
  static List<Map<String, dynamic>>? _cachedProducts;

  // Backend category names (from the real DB, e.g. "Fruits", "Shampoo")
  // don't line up 1:1 with the mock taxonomy's category titles (e.g.
  // "Vegetables & Fruits", "Hair"). Matching on exact title equality meant
  // every backend product silently failed to match and the screen fell
  // back to fully-mock (non-purchasable) products. This maps each real
  // backend category name to the mock categoryId it should appear under,
  // so real products route into a real tab and stay purchasable.
  static const Map<String, String> _backendToMockCategoryId = {
    'fruits': 'cat_veg_fruits',
    'chocolate': 'cat_sweets_choco',
    'beverages': 'cat_drinks_juices',
    'ice creams': 'cat_ice_creams',
    'bakery': 'cat_bakery_biscuits',
    'biscuits': 'cat_biscuits',
    'namkeen': 'cat_chips_namkeen',
    'wafers': 'cat_chips',
    'ketchup': 'cat_sauces_spreads',
    'shampoo': 'cat_hair',
    'soap': 'cat_bath_body',
    'personal care': 'cat_bath_body',
    'pickle': 'cat_sauces_spreads',
    'puja items': 'cat_home_lifestyle',
    'toys': 'cat_stationery_games',
    'clothes': 'cat_clothes',
    'atta & rice': 'cat_atta_rice_dal',
    'oil & spices': 'cat_oil_ghee_masala',
    'dairy & eggs': 'cat_dairy_bread_eggs',
    'dry fruits': 'cat_dryfruits_cereals',
    'kitchenware': 'cat_kitchenware',
    'meat & fish': 'cat_chicken_meat_fish',
    'tea & coffee': 'cat_tea_coffee',
    'instant food': 'cat_instant_food',
    'mouth fresheners': 'cat_paan_corner',
    'skin care': 'cat_skin_face',
    'feminine hygiene': 'cat_feminine_hygiene',
    'baby care': 'cat_baby_care',
    'health care': 'cat_health_pharma',
    'cleaning supplies': 'cat_cleaners_repellents',
    'electronics': 'cat_electronics',
  };

  /// True if a backend product's category name belongs on this mock
  /// [categoryId]'s tab, using the explicit mapping above (falling back to
  /// exact title equality for any backend category not yet mapped, so new
  /// categories that happen to share their exact name with a mock one
  /// still work automatically).
  bool _backendCategoryBelongsTo(String backendCategoryName, CategoryModel category) {
    final key = backendCategoryName.toLowerCase();
    final mappedId = _backendToMockCategoryId[key];
    if (mappedId != null) return mappedId == category.id;
    return key == category.title.toLowerCase();
  }

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

  // Category ids to hide from the Home screen's category grid only.
  // They stay fully visible/browsable in the Categories tab - this list
  // only controls what shows up inline on Home.
  static const Set<String> _hiddenOnHome = {'cat_chips', 'cat_biscuits'};

  Future<List<CategorySectionModel>> fetchHomeSections() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return CategoryMockData.sections
        .map((section) => CategorySectionModel(
              id: section.id,
              title: section.title,
              categories: section.categories
                  .where((c) => !_hiddenOnHome.contains(c.id))
                  .toList(),
            ))
        .where((section) => section.categories.isNotEmpty)
        .toList();
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

  // Backend image_url comes back as a relative path (e.g. "/uploads/x.png").
  // ProductCard decides network-vs-asset purely by checking if the string
  // starts with "http", so without this prefix it was treated as a bundled
  // asset (and failed to load, since it isn't one).
  static String _resolveImageUrl(String url) {
    if (url.isEmpty || url.startsWith('http')) return url;
    final host = ApiService.baseUrl.replaceAll('/api/v1', '');
    return '$host$url';
  }

  ProductModel _fromBackend(Map<String, dynamic> raw, CategoryModel category, int index) {
    final price = (raw['price'] is num) ? (raw['price'] as num).toDouble() : 0.0;
    final imgUrl = _resolveImageUrl((raw['image_url'] ?? '').toString());
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
        .where((p) => _backendCategoryBelongsTo(_categoryName(p), category))
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

    final result = <ProductModel>[];
    for (var s = 0; s < bucketCount; s++) {
      result.addAll(buckets[s]);
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
        final mappedId = _backendToMockCategoryId[catName.toLowerCase()];
        final allCategories =
            CategoryMockData.sections.expand((s) => s.categories);
        final category = allCategories.firstWhere(
          (c) => mappedId != null
              ? c.id == mappedId
              : c.title.toLowerCase() == catName.toLowerCase(),
          orElse: () => allCategories.first,
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
              _backendCategoryBelongsTo(_categoryName(p), category) && p['id'] != intId)
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
