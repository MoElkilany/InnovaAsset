import 'package:hive/hive.dart';
import 'package:innova/features/asset_registration/data/models/asset_description_model.dart';
import 'package:innova/features/asset_registration/data/models/asset_model.dart';
import 'package:innova/features/asset_registration/data/models/category_model.dart';
import 'package:innova/features/asset_registration/data/models/location_model.dart';

/// Local data source using Hive for offline storage.
abstract interface class AssetLocalSource {
  Future<void> saveAsset(AssetModel asset);
  Future<List<AssetModel>> getAssets();
  Future<List<CategoryModel>> getCategories();
  Future<List<LocationModel>> getLocations();
  Future<List<AssetDescriptionModel>> getDescriptions();
  Future<void> saveCategories(List<CategoryModel> categories);
  Future<void> saveLocations(List<LocationModel> locations);
  Future<void> saveDescriptions(List<AssetDescriptionModel> descriptions);
  Future<void> addCategory(CategoryModel category);
  Future<void> addLocation(LocationModel location);
  Future<void> addDescription(AssetDescriptionModel description);
  Future<void> clearLookups();
}

/// Implementation of AssetLocalSource using Hive.
class AssetLocalSourceImpl implements AssetLocalSource {
  final Box<AssetModel> _assetsBox;
  final Box<CategoryModel> _categoriesBox;
  final Box<LocationModel> _locationsBox;
  final Box<AssetDescriptionModel> _descriptionsBox;

  AssetLocalSourceImpl({
    required Box<AssetModel> assetsBox,
    required Box<CategoryModel> categoriesBox,
    required Box<LocationModel> locationsBox,
    required Box<AssetDescriptionModel> descriptionsBox,
  })  : _assetsBox = assetsBox,
        _categoriesBox = categoriesBox,
        _locationsBox = locationsBox,
        _descriptionsBox = descriptionsBox;

  @override
  Future<void> saveAsset(AssetModel asset) async {
    await _assetsBox.put(asset.id, asset);
  }

  @override
  Future<List<AssetModel>> getAssets() async {
    return _assetsBox.values.toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    return _categoriesBox.values.toList();
  }

  @override
  Future<List<LocationModel>> getLocations() async {
    return _locationsBox.values.toList();
  }

  @override
  Future<List<AssetDescriptionModel>> getDescriptions() async {
    return _descriptionsBox.values.toList();
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _categoriesBox.clear();
    for (final category in categories) {
      await _categoriesBox.put(category.id, category);
    }
  }

  @override
  Future<void> saveLocations(List<LocationModel> locations) async {
    await _locationsBox.clear();
    for (final location in locations) {
      await _locationsBox.put(location.id, location);
    }
  }

  @override
  Future<void> saveDescriptions(
      List<AssetDescriptionModel> descriptions) async {
    await _descriptionsBox.clear();
    for (final description in descriptions) {
      await _descriptionsBox.put(description.id, description);
    }
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  @override
  Future<void> addLocation(LocationModel location) async {
    await _locationsBox.put(location.id, location);
  }

  @override
  Future<void> addDescription(AssetDescriptionModel description) async {
    await _descriptionsBox.put(description.id, description);
  }

  @override
  Future<void> clearLookups() async {
    await Future.wait([
      _categoriesBox.clear(),
      _locationsBox.clear(),
      _descriptionsBox.clear(),
    ]);
  }
}
