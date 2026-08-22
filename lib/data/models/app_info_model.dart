class AppInfoModel {
  final String appName;
  final String version;
  final String buildNumber;
  final String company;
  final String termsUrl;
  final String privacyUrl;

  AppInfoModel({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.company,
    required this.termsUrl,
    required this.privacyUrl,
  });

  factory AppInfoModel.fromJson(Map<String, dynamic> json) {
    return AppInfoModel(
      appName: json['appName'] ?? '',
      version: json['version'] ?? '',
      buildNumber: json['buildNumber'] ?? '',
      company: json['company'] ?? '',
      termsUrl: json['termsUrl'] ?? '',
      privacyUrl: json['privacyUrl'] ?? '',
    );
  }
}
