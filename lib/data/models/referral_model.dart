class ReferralModel {
  final String referralCode;
  final double totalEarnings;
  final int totalReferred;

  ReferralModel({
    required this.referralCode,
    required this.totalEarnings,
    required this.totalReferred,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      referralCode: json['referralCode'] ?? '',
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      totalReferred: json['totalReferred'] ?? 0,
    );
  }
}
