import 'package:dio/dio.dart';
import 'package:innova/features/asset_registration/data/models/asset_description_model.dart';
import 'package:innova/features/asset_registration/data/models/category_model.dart';
import 'package:innova/features/asset_registration/data/models/location_model.dart';

/// Remote data source for fetching lookup data from API.
abstract interface class LookupRemoteSource {
  Future<List<CategoryModel>> fetchCategories();
  Future<List<LocationModel>> fetchLocations();
  Future<List<AssetDescriptionModel>> fetchDescriptions();
}

/// Implementation of LookupRemoteSource using Dio.
class LookupRemoteSourceImpl implements LookupRemoteSource {
  final Dio _dio;

  LookupRemoteSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _dio.get('/api/lookups/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data
            .map((item) => CategoryModel(
                  id: item['id'] as String,
                  name: item['name'] as String,
                  isLocal: false,
                ))
            .toList();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to fetch categories',
      );
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<LocationModel>> fetchLocations() async {
    try {
      final response = await _dio.get('/api/lookups/locations');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data
            .map((item) => LocationModel(
                  id: item['id'] as String,
                  name: item['name'] as String,
                  isLocal: false,
                ))
            .toList();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to fetch locations',
      );
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<AssetDescriptionModel>> fetchDescriptions() async {
    try {
      final response = await _dio.get('/api/lookups/descriptions');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data
            .map((item) => AssetDescriptionModel(
                  id: item['id'] as String,
                  label: item['label'] as String,
                  isLocal: false,
                ))
            .toList();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to fetch descriptions',
      );
    } on DioException {
      rethrow;
    }
  }
}
