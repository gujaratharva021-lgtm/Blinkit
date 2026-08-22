class GstEntity {
  final String id;
  final String gstNumber;
  final String businessName;
  final String businessAddress;

  const GstEntity({
    required this.id,
    required this.gstNumber,
    required this.businessName,
    required this.businessAddress,
  });

  GstEntity copyWith({
    String? id,
    String? gstNumber,
    String? businessName,
    String? businessAddress,
  }) {
    return GstEntity(
      id: id ?? this.id,
      gstNumber: gstNumber ?? this.gstNumber,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
    );
  }
}

