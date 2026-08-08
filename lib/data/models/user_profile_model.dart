class UserProfileModel {
  final String name;
  final String email;
  final String phone;
  final String gender;
  final DateTime? dob;
  final String? avatarPath;

  UserProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    this.dob,
    this.avatarPath,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 'Not specified',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      avatarPath: json['avatarPath'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'dob': dob?.toIso8601String(),
        'avatarPath': avatarPath,
      };

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? gender,
    DateTime? dob,
    String? avatarPath,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
