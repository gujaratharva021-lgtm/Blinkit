import 'package:flutter/foundation.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistRepository repository;

  WishlistProvider({required this.repository});

  ViewStatus status = ViewStatus.initial;
  String? errorMessage;
  List<WishlistItemEntity> items = [];
  final Set<String> pendingIds = {};

  Future<void> loadWishlist() async {
    status = ViewStatus.loading;
    notifyListeners();

    final result = await repository.getWishlist();
    if (result.isSuccess) {
      items = result.data ?? [];
      status = items.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    } else {
      status = ViewStatus.error;
      errorMessage = result.failure?.message;
    }
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    pendingIds.add(id);
    notifyListeners();

    final result = await repository.removeFromWishlist(id);
    pendingIds.remove(id);
    if (result.isSuccess) {
      items = items.where((item) => item.id != id).toList();
      status = items.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    }
    notifyListeners();
  }

  Future<bool> moveToCart(String id) async {
    pendingIds.add(id);
    notifyListeners();

    final result = await repository.moveToCart(id);
    pendingIds.remove(id);
    if (result.isSuccess) {
      items = items.where((item) => item.id != id).toList();
      status = items.isEmpty ? ViewStatus.empty : ViewStatus.loaded;
    }
    notifyListeners();
    return result.isSuccess;
  }
}

