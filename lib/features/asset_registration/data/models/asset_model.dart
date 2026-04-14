import 'package:hive/hive.dart';

part 'asset_model.g.dart';

@HiveType(typeId: 0)
class AssetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String descriptionId;

  @HiveField(2)
  String code;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  String locationId;

  @HiveField(5)
  String status;

  @HiveField(6)
  String details;

  @HiveField(7)
  String imagePath;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  bool isSynced;

  AssetModel({
    required this.id,
    required this.descriptionId,
    required this.code,
    required this.categoryId,
    required this.locationId,
    required this.status,
    required this.details,
    required this.imagePath,
    required this.createdAt,
    required this.isSynced,
  });

  AssetModel copyWith({
    String? id,
    String? descriptionId,
    String? code,
    String? categoryId,
    String? locationId,
    String? status,
    String? details,
    String? imagePath,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return AssetModel(
      id: id ?? this.id,
      descriptionId: descriptionId ?? this.descriptionId,
      code: code ?? this.code,
      categoryId: categoryId ?? this.categoryId,
      locationId: locationId ?? this.locationId,
      status: status ?? this.status,
      details: details ?? this.details,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
