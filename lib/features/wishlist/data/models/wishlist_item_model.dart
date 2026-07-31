import '../../domain/entities/wishlist_item_entity.dart';

class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({
    required super.id,
    required super.productId,
    required super.name,
    required super.imageUrl,
    required super.price,
    required super.mrp,
    required super.discountPercent,
    required super.rating,
    required super.ratingCount,
    super.inStock = true,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      mrp: (json['mrp'] as num).toDouble(),
      discountPercent: json['discountPercent'] as int,
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
      inStock: json['inStock'] as bool? ?? true,
    );
  }
}

