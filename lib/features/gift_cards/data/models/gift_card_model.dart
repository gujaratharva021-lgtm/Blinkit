import '../../domain/entities/gift_card_entity.dart';

class GiftCardModel extends GiftCardEntity {
  const GiftCardModel({
    required super.id,
    required super.cardNumber,
    required super.balance,
    required super.expiryDate,
    required super.status,
  });

  factory GiftCardModel.fromJson(Map<String, dynamic> json) {
    return GiftCardModel(
      id: json['id'] as String,
      cardNumber: json['cardNumber'] as String,
      balance: (json['balance'] as num).toDouble(),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      status: _statusFromString(json['status'] as String),
    );
  }

  static GiftCardStatus _statusFromString(String value) {
    switch (value) {
      case 'redeemed':
        return GiftCardStatus.redeemed;
      case 'expired':
        return GiftCardStatus.expired;
      case 'active':
      default:
        return GiftCardStatus.active;
    }
  }
}

