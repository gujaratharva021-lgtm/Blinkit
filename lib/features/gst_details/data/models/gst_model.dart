import '../../domain/entities/gst_entity.dart';

class GstModel extends GstEntity {
  const GstModel({
    required super.id,
    required super.gstNumber,
    required super.businessName,
    required super.businessAddress,
  });

  factory GstModel.fromJson(Map<String, dynamic> json) {
    return GstModel(
      id: json['id'] as String,
      gstNumber: json['gstNumber'] as String,
      businessName: json['businessName'] as String,
      businessAddress: json['businessAddress'] as String,
    );
  }

  factory GstModel.fromEntity(GstEntity entity) {
    return GstModel(
      id: entity.id,
      gstNumber: entity.gstNumber,
      businessName: entity.businessName,
      businessAddress: entity.businessAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gstNumber': gstNumber,
      'businessName': businessName,
      'businessAddress': businessAddress,
    };
  }
}

