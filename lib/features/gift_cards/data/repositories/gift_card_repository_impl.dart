import 'package:dio/dio.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/entities/gift_card_entity.dart';
import '../../domain/repositories/gift_card_repository.dart';
import '../datasources/gift_card_mock_datasource.dart';

class GiftCardRepositoryImpl implements GiftCardRepository {
  final GiftCardMockDataSource dataSource;

  GiftCardRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<GiftCardEntity>>> getActiveCards() async {
    try {
      final result = await dataSource.fetchActiveCards();
      return Result.success(result);
    } on DioException catch (e) {
      return Result.failure(AppFailure(e.error?.toString() ?? 'Network error'));
    } catch (e) {
      return Result.failure(AppFailure('Failed to load active cards'));
    }
  }

  @override
  Future<Result<List<GiftCardEntity>>> getRedeemedCards() async {
    try {
      final result = await dataSource.fetchRedeemedCards();
      return Result.success(result);
    } on DioException catch (e) {
      return Result.failure(AppFailure(e.error?.toString() ?? 'Network error'));
    } catch (e) {
      return Result.failure(AppFailure('Failed to load redeemed cards'));
    }
  }

  @override
  Future<Result<GiftCardEntity>> redeemCard(String code) async {
    try {
      final result = await dataSource.redeemCard(code);
      return Result.success(result);
    } on DioException catch (e) {
      return Result.failure(AppFailure(e.error?.toString() ?? 'Redemption failed'));
    } catch (e) {
      return Result.failure(AppFailure('Redemption failed. Please try again.'));
    }
  }
}

