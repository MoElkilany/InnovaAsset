import 'package:innova/core/error/failures.dart';
import 'package:innova/features/asset_registration/data/models/asset_description_model.dart';
import 'package:innova/features/asset_registration/data/models/category_model.dart';
import 'package:innova/features/asset_registration/data/models/location_model.dart';
import 'package:innova/features/asset_registration/domain/repositories/asset_repository.dart';

/// Bundle of all lookup data.
class LookupBundle {
  final List<CategoryModel> categories;
  final List<LocationModel> locations;
  final List<AssetDescriptionModel> descriptions;

  const LookupBundle({
    required this.categories,
    required this.locations,
    required this.descriptions,
  });
}

/// Use case for fetching all lookup data (categories, locations, descriptions).
class FetchLookupsUseCase {
  final AssetRepository _repository;

  FetchLookupsUseCase({required AssetRepository repository})
      : _repository = repository;

  Future<(Failure?, LookupBundle?)> call() async {
    final categoriesResult = await _repository.getCategories();
    final locationsResult = await _repository.getLocations();
    final descriptionsResult = await _repository.getDescriptions();

    // If any fetch fails, return the first failure
    if (categoriesResult.$1 != null) {
      return (categoriesResult.$1, null);
    }
    if (locationsResult.$1 != null) {
      return (locationsResult.$1, null);
    }
    if (descriptionsResult.$1 != null) {
      return (descriptionsResult.$1, null);
    }

    final bundle = LookupBundle(
      categories: categoriesResult.$2 ?? [],
      locations: locationsResult.$2 ?? [],
      descriptions: descriptionsResult.$2 ?? [],
    );

    return (null, bundle);
  }
}
