import '../../domain/entities/address_entity.dart';

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
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      mobileNumber: json['mobileNumber'] as String,
      houseNumber: json['houseNumber'] as String,
      areaStreet: json['areaStreet'] as String,
      landmark: json['landmark'] as String? ?? '',
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
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
    );
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
    };
  }
}

