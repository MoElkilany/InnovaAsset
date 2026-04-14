import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isLocal;

  CategoryModel({
    required this.id,
    required this.name,
    required this.isLocal,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    bool? isLocal,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
