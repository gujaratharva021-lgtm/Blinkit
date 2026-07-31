import '../../../../core/utils/view_state.dart';
import '../entities/wishlist_item_entity.dart';

abstract class WishlistRepository {
  Future<Result<List<WishlistItemEntity>>> getWishlist();
  Future<Result<bool>> removeFromWishlist(String id);
  Future<Result<bool>> moveToCart(String id);
}

