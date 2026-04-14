import 'package:hive/hive.dart';

part 'location_model.g.dart';

@HiveType(typeId: 2)
class LocationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isLocal;

  LocationModel({
    required this.id,
    required this.name,
    required this.isLocal,
  });

  LocationModel copyWith({
    String? id,
    String? name,
    bool? isLocal,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
