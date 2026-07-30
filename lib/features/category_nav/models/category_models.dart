import 'package:flutter/material.dart';

/// Generic async load state used by the category-navigation feature
/// (home sections, category products, etc).
enum LoadStatus { idle, loading, loaded, empty, error }

/// Sort options available on [CategoryProductScreen].
enum SortOption { relevance, priceLowToHigh, priceHighToLow, discount, rating }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.discount:
        return 'Discount';
      case SortOption.rating:
        return 'Rating';
    }
  }
}

/// A single product shown in the category product grid and on the
/// product details page. Uses an [icon]/[color] pair as a placeholder
/// image since this module runs on mock data only â€” swap in a real
/// `imageUrl` + `CachedNetworkImage` once product photography/API is
/// available.
class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String weight;
  final double price;
  final double mrp;
  final double rating;
  final int ratingCount;
  final IconData icon;
  final Color color;
  final String categoryId;
  final String subCategoryId;
  final String description;
  final List<String> nutrition;
  final String deliveryTime;
  final bool inStock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.weight,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.ratingCount,
    required this.icon,
    required this.color,
    required this.categoryId,
    required this.subCategoryId,
    required this.description,
    required this.nutrition,
    required this.deliveryTime,
    this.inStock = true,
  });

  int get discountPercent =>
      mrp > price ? (((mrp - price) / mrp) * 100).round() : 0;

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || brand.toLowerCase().contains(q);
  }
}

/// A subcategory belonging to a [CategoryModel], e.g. "Fresh Vegetables"
/// under "Vegetables & Fruits".
class SubCategoryModel {
  final String id;
  final String title;
  final String categoryId;
  final IconData icon;

  const SubCategoryModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.icon,
  });
}

/// A single tappable category tile, e.g. "Vegetables & Fruits".
/// Belongs to a [CategorySectionModel] and owns a list of subcategories.
class CategoryModel {
  final String id;
  final String title;
  final String sectionId;
  final IconData icon;
  final Color color;
  final List<SubCategoryModel> subCategories;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.sectionId,
    required this.icon,
    required this.color,
    required this.subCategories,
  });
}

/// A home-screen category section, e.g. "Grocery & Kitchen", made up of
/// several [CategoryModel]s rendered as a 4-column grid.
class CategorySectionModel {
  final String id;
  final String title;
  final List<CategoryModel> categories;

  const CategorySectionModel({
    required this.id,
    required this.title,
    required this.categories,
  });
}
