class AddressEntity {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String houseNumber;
  final String areaStreet;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const AddressEntity({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.houseNumber,
    required this.areaStreet,
    this.landmark = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  AddressEntity copyWith({
    String? id,
    String? fullName,
    String? mobileNumber,
    String? houseNumber,
    String? areaStreet,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      houseNumber: houseNumber ?? this.houseNumber,
      areaStreet: areaStreet ?? this.areaStreet,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  String get oneLineAddress =>
      '$houseNumber, $areaStreet${landmark.isNotEmpty ? ", $landmark" : ""}, $city, $state - $pincode';
}
