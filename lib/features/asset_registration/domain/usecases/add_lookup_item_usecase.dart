import 'package:innova/core/error/failures.dart';
import 'package:innova/features/asset_registration/data/models/asset_description_model.dart';
import 'package:innova/features/asset_registration/data/models/category_model.dart';
import 'package:innova/features/asset_registration/data/models/location_model.dart';
import 'package:innova/features/asset_registration/domain/repositories/asset_repository.dart';
import 'package:uuid/uuid.dart';

/// Enum for lookup item types.
enum LookupType {
  category,
  location,
  description,
}

/// Use case for adding a new lookup item (category, location, or description).
class AddLookupItemUseCase {
  final AssetRepository _repository;

  AddLookupItemUseCase({required AssetRepository repository})
      : _repository = repository;

  Future<(Failure?, void)> call(LookupType type, String name) async {
    final id = const Uuid().v4();

    return switch (type) {
      LookupType.category => _repository.addCategory(
          CategoryModel(id: id, name: name, isLocal: true),
        ),
      LookupType.location => _repository.addLocation(
          LocationModel(id: id, name: name, isLocal: true),
        ),
      LookupType.description => _repository.addDescription(
          AssetDescriptionModel(id: id, label: name, isLocal: true),
        ),
    };
  }
}
