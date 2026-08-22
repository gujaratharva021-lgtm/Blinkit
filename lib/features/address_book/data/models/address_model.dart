import '../../domain/entities/address_entity.dart';

/// Maps to the backend's Address model (see internal/models/address.go):
/// id (int), user_id, label, full_name, phone, line1, line2, city, state,
/// pincode, lat, lng, is_default. houseNumber -> label, areaStreet -> line1,
/// landmark -> line2 (there's no separate landmark field on the backend).
class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.fullName,
    required super.mobileNumber,
    required super.houseNumber,
    required super.areaStreet,
    super.landmark = '',
    required super.city,
    required super.state,
    required super.pincode,
    super.isDefault = false,
    super.latitude,
    super.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      fullName: json['full_name'] as String? ?? '',
      mobileNumber: json['phone'] as String? ?? '',
      houseNumber: json['label'] as String? ?? '',
      areaStreet: json['line1'] as String? ?? '',
      landmark: json['line2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lng'] as num?)?.toDouble(),
    );
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      fullName: entity.fullName,
      mobileNumber: entity.mobileNumber,
      houseNumber: entity.houseNumber,
      areaStreet: entity.areaStreet,
      landmark: entity.landmark,
      city: entity.city,
      state: entity.state,
      pincode: entity.pincode,
      isDefault: entity.isDefault,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  /// Body for POST/PUT /addresses - omits id (server-assigned) and maps
  /// field names to what the backend expects.
  Map<String, dynamic> toRequestJson() {
    return {
      'label': houseNumber.isNotEmpty ? houseNumber : 'Home',
      'full_name': fullName,
      'phone': mobileNumber,
      'line1': areaStreet,
      'line2': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
      if (latitude != null) 'lat': latitude,
      if (longitude != null) 'lng': longitude,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'houseNumber': houseNumber,
      'areaStreet': areaStreet,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
