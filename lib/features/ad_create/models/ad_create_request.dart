import 'dart:io';

class AdCreateImageFile {
  final File file;

  const AdCreateImageFile({
    required this.file,
  });
}

class AdCreateRequest {
  final int categoryId;
  final int cityId;
  final int? districtId;
  final int price;
  final String currency;
  final String condition;
  final String? description;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactMethod;
  final bool hasDelivery;
  final bool postAsStore;
  final int coverIndex;
  final Map<String, dynamic> attributes;
  final List<AdCreateImageFile> images;

  const AdCreateRequest({
    required this.categoryId,
    required this.cityId,
    this.districtId,
    required this.price,
    required this.currency,
    required this.condition,
    this.description,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.contactMethod,
    required this.hasDelivery,
    required this.postAsStore,
    required this.coverIndex,
    required this.attributes,
    required this.images,
  });
}