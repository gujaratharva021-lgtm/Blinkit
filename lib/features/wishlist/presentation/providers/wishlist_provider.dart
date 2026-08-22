import 'package:flutter/foundation.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/entities/wishlist_item_entity.dart';

class WishlistProvider extends ChangeNotifier {
  ViewStatus status = ViewStatus.empty;
  String? errorMessage;
  List<WishlistItemEntity> items = [];
  final Set<String> pendingIds = {};

  Future<void> loadWishlist() async {
    status = items.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    notifyListeners();
  }

  bool isWishlisted(String productId) =>
      items.any((item) => item.productId == productId);

  /// Adds the product if it isn't already saved, removes it if it is.
  void toggle(WishlistItemEntity item) {
    if (isWishlisted(item.productId)) {
      items = items.where((i) => i.productId != item.productId).toList();
    } else {
      items = [...items, item];
    }
    status = items.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    items = items.where((item) => item.id != id).toList();
    status = items.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    notifyListeners();
  }

  Future<bool> moveToCart(String id) async {
    items = items.where((item) => item.id != id).toList();
    status = items.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    notifyListeners();
    return true;
  }
}
