import '../../../../core/utils/view_state.dart';
import '../entities/gift_card_entity.dart';

abstract class GiftCardRepository {
  Future<Result<List<GiftCardEntity>>> getActiveCards();
  Future<Result<List<GiftCardEntity>>> getRedeemedCards();
  Future<Result<GiftCardEntity>> redeemCard(String code);
}

