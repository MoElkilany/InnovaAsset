import 'package:hive/hive.dart';

part 'asset_description_model.g.dart';

@HiveType(typeId: 3)
class AssetDescriptionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  bool isLocal;

  AssetDescriptionModel({
    required this.id,
    required this.label,
    required this.isLocal,
  });

  AssetDescriptionModel copyWith({
    String? id,
    String? label,
    bool? isLocal,
  }) {
    return AssetDescriptionModel(
      id: id ?? this.id,
      label: label ?? this.label,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
