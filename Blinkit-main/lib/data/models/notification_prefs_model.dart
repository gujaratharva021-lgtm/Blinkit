class NotificationPrefsModel {
  final bool orders;
  final bool offers;
  final bool wallet;
  final bool recommendations;
  final bool updates;

  NotificationPrefsModel({
    required this.orders,
    required this.offers,
    required this.wallet,
    required this.recommendations,
    required this.updates,
  });

  factory NotificationPrefsModel.fromJson(Map<String, dynamic> json) {
    return NotificationPrefsModel(
      orders: json['orders'] ?? true,
      offers: json['offers'] ?? true,
      wallet: json['wallet'] ?? true,
      recommendations: json['recommendations'] ?? false,
      updates: json['updates'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'orders': orders,
        'offers': offers,
        'wallet': wallet,
        'recommendations': recommendations,
        'updates': updates,
      };

  NotificationPrefsModel copyWith({
    bool? orders,
    bool? offers,
    bool? wallet,
    bool? recommendations,
    bool? updates,
  }) {
    return NotificationPrefsModel(
      orders: orders ?? this.orders,
      offers: offers ?? this.offers,
      wallet: wallet ?? this.wallet,
      recommendations: recommendations ?? this.recommendations,
      updates: updates ?? this.updates,
    );
  }
}
