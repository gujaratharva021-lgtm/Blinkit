import '../data/category_mock_data.dart';
import '../models/category_models.dart';

/// Frontend-only repository. Wraps [CategoryMockData] with a small
/// artificial delay so loading/skeleton states have something to show.
/// Swap the method bodies for real API/Dio calls once a backend exists â€”
/// the public signatures are written to be a drop-in replacement.
class CategoryRepository {
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

  Future<List<ProductModel>> fetchProducts({required String categoryId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return CategoryMockData.productsForCategory(categoryId);
  }

  Future<ProductModel> fetchProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return CategoryMockData.allProducts.firstWhere((p) => p.id == productId);
  }

  Future<List<ProductModel>> fetchSimilarProducts(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CategoryMockData.allProducts
        .where((p) => p.categoryId == product.categoryId && p.id != product.id)
        .take(10)
        .toList();
  }
}
