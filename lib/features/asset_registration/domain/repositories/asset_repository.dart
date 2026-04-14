import 'package:innova/core/error/failures.dart';
import 'package:innova/features/asset_registration/data/models/asset_description_model.dart';
import 'package:innova/features/asset_registration/data/models/asset_model.dart';
import 'package:innova/features/asset_registration/data/models/category_model.dart';
import 'package:innova/features/asset_registration/data/models/location_model.dart';

/// Repository contract for asset-related operations.
abstract interface class AssetRepository {
  // Lookup data retrieval
  Future<(Failure?, List<CategoryModel>?)> getCategories();
  Future<(Failure?, List<LocationModel>?)> getLocations();
  Future<(Failure?, List<AssetDescriptionModel>?)> getDescriptions();
  Future<(Failure?, void)> refreshLookups();

  // Asset CRUD
  Future<(Failure?, void)> saveAsset(AssetModel asset);
  Future<(Failure?, List<AssetModel>?)> getSavedAssets();

  // Add custom lookup items
  Future<(Failure?, void)> addCategory(CategoryModel category);
  Future<(Failure?, void)> addLocation(LocationModel location);
  Future<(Failure?, void)> addDescription(AssetDescriptionModel description);
}
