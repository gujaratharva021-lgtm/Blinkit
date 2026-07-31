import 'package:dio/dio.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_mock_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistMockDataSource dataSource;

  WishlistRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<WishlistItemEntity>>> getWishlist() async {
    try {
      final result = await dataSource.fetchWishlist();
      return Result.success(result);
    } on DioException catch (e) {
      return Result.failure(AppFailure(e.error?.toString() ?? 'Network error'));
    } catch (e) {
      return Result.failure(AppFailure('Failed to load wishlist'));
    }
  }

  @override
  Future<Result<bool>> removeFromWishlist(String id) async {
    try {
      final ok = await dataSource.removeFromWishlist(id);
      return Result.success(ok);
    } catch (e) {
      return Result.failure(AppFailure('Failed to remove item'));
    }
  }

  @override
  Future<Result<bool>> moveToCart(String id) async {
    try {
      final ok = await dataSource.moveToCart(id);
      return Result.success(ok);
    } catch (e) {
      return Result.failure(AppFailure('Failed to move item to cart'));
    }
  }
}

