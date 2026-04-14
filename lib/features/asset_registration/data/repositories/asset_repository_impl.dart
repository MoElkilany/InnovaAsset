import 'package:dio/dio.dart';
import 'package:innova/core/error/failures.dart';
import 'package:innova/features/asset_registration/data/models/asset_description_model.dart';
import 'package:innova/features/asset_registration/data/models/asset_model.dart';
import 'package:innova/features/asset_registration/data/models/category_model.dart';
import 'package:innova/features/asset_registration/data/models/location_model.dart';
import 'package:innova/features/asset_registration/data/sources/asset_local_source.dart';
import 'package:innova/features/asset_registration/data/sources/lookup_remote_source.dart';
import 'package:innova/features/asset_registration/domain/repositories/asset_repository.dart';
import 'package:innova/services/connectivity_service.dart';

/// Implementation of AssetRepository using local and remote sources.
class AssetRepositoryImpl implements AssetRepository {
  final AssetLocalSource _localSource;
  final LookupRemoteSource _remoteSource;
  final ConnectivityService _connectivityService;

  AssetRepositoryImpl({
    required AssetLocalSource localSource,
    required LookupRemoteSource remoteSource,
    required ConnectivityService connectivityService,
  })  : _localSource = localSource,
        _remoteSource = remoteSource,
        _connectivityService = connectivityService;

  @override
  Future<(Failure?, List<CategoryModel>?)> getCategories() async {
    try {
      final cached = await _localSource.getCategories();
      if (cached.isNotEmpty) {
        return (null, cached);
      }

      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return (
          const CacheFailure('No cached categories available'),
          null,
        );
      }

      final remote = await _remoteSource.fetchCategories();
      await _localSource.saveCategories(remote);
      return (null, remote);
    } on DioException catch (e) {
      return (NetworkFailure(e.message ?? 'Failed to fetch categories'), null);
    } catch (e) {
      return (CacheFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, List<LocationModel>?)> getLocations() async {
    try {
      final cached = await _localSource.getLocations();
      if (cached.isNotEmpty) {
        return (null, cached);
      }

      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return (
          const CacheFailure('No cached locations available'),
          null,
        );
      }

      final remote = await _remoteSource.fetchLocations();
      await _localSource.saveLocations(remote);
      return (null, remote);
    } on DioException catch (e) {
      return (NetworkFailure(e.message ?? 'Failed to fetch locations'), null);
    } catch (e) {
      return (CacheFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, List<AssetDescriptionModel>?)> getDescriptions() async {
    try {
      final cached = await _localSource.getDescriptions();
      if (cached.isNotEmpty) {
        return (null, cached);
      }

      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return (
          const CacheFailure('No cached descriptions available'),
          null,
        );
      }

      final remote = await _remoteSource.fetchDescriptions();
      await _localSource.saveDescriptions(remote);
      return (null, remote);
    } on DioException catch (e) {
      return (
        NetworkFailure(e.message ?? 'Failed to fetch descriptions'),
        null,
      );
    } catch (e) {
      return (CacheFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> refreshLookups() async {
    try {
      final isOnline = await _connectivityService.isConnected;
      if (!isOnline) {
        return (const NetworkFailure('No internet connection'), null);
      }

      final categories = await _remoteSource.fetchCategories();
      final locations = await _remoteSource.fetchLocations();
      final descriptions = await _remoteSource.fetchDescriptions();

      // Merge with local items
      final cachedCategories = await _localSource.getCategories();
      final localCategories =
          cachedCategories.where((c) => c.isLocal).toList();
      categories.addAll(localCategories);

      final cachedLocations = await _localSource.getLocations();
      final localLocations = cachedLocations.where((l) => l.isLocal).toList();
      locations.addAll(localLocations);

      final cachedDescriptions = await _localSource.getDescriptions();
      final localDescriptions =
          cachedDescriptions.where((d) => d.isLocal).toList();
      descriptions.addAll(localDescriptions);

      await Future.wait([
        _localSource.saveCategories(categories),
        _localSource.saveLocations(locations),
        _localSource.saveDescriptions(descriptions),
      ]);

      return (null, null);
    } on DioException catch (e) {
      return (NetworkFailure(e.message ?? 'Failed to refresh lookups'), null);
    } catch (e) {
      return (CacheFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> saveAsset(AssetModel asset) async {
    try {
      await _localSource.saveAsset(asset);
      return (null, null);
    } catch (e) {
      return (CacheFailure('Failed to save asset: ${e.toString()}'), null);
    }
  }

  @override
  Future<(Failure?, List<AssetModel>?)> getSavedAssets() async {
    try {
      final assets = await _localSource.getAssets();
      return (null, assets);
    } catch (e) {
      return (CacheFailure('Failed to retrieve assets: ${e.toString()}'), null);
    }
  }

  @override
  Future<(Failure?, void)> addCategory(CategoryModel category) async {
    try {
      await _localSource.addCategory(category);
      return (null, null);
    } catch (e) {
      return (
        CacheFailure('Failed to add category: ${e.toString()}'),
        null,
      );
    }
  }

  @override
  Future<(Failure?, void)> addLocation(LocationModel location) async {
    try {
      await _localSource.addLocation(location);
      return (null, null);
    } catch (e) {
      return (
        CacheFailure('Failed to add location: ${e.toString()}'),
        null,
      );
    }
  }

  @override
  Future<(Failure?, void)> addDescription(
      AssetDescriptionModel description) async {
    try {
      await _localSource.addDescription(description);
      return (null, null);
    } catch (e) {
      return (
        CacheFailure('Failed to add description: ${e.toString()}'),
        null,
      );
    }
  }
}
