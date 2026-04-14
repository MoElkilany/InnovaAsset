import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:innova/core/constants/app_constants.dart';
import 'package:innova/features/asset_registration/data/models/asset_description_model.dart';
import 'package:innova/features/asset_registration/data/models/asset_model.dart';
import 'package:innova/features/asset_registration/data/models/category_model.dart';
import 'package:innova/features/asset_registration/data/models/location_model.dart';
import 'package:innova/features/asset_registration/data/repositories/asset_repository_impl.dart';
import 'package:innova/features/asset_registration/data/sources/asset_local_source.dart';
import 'package:innova/features/asset_registration/data/sources/lookup_remote_source.dart';
import 'package:innova/features/asset_registration/domain/repositories/asset_repository.dart';
import 'package:innova/features/asset_registration/domain/usecases/add_lookup_item_usecase.dart';
import 'package:innova/features/asset_registration/domain/usecases/fetch_lookups_usecase.dart';
import 'package:innova/features/asset_registration/domain/usecases/save_asset_usecase.dart';
import 'package:innova/services/connectivity_service.dart';

final getIt = GetIt.instance;

/// Sets up all dependency injection for the app.
Future<void> setupLocator() async {
  // HTTP Client
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  getIt.registerSingleton<Dio>(dio);

  // Data Sources
  final assetsBox = Hive.box<AssetModel>(AppConstants.assetsBox);
  final categoriesBox = Hive.box<CategoryModel>(AppConstants.categoriesBox);
  final locationsBox = Hive.box<LocationModel>(AppConstants.locationsBox);
  final descriptionsBox =
      Hive.box<AssetDescriptionModel>(AppConstants.descriptionsBox);

  final localSource = AssetLocalSourceImpl(
    assetsBox: assetsBox,
    categoriesBox: categoriesBox,
    locationsBox: locationsBox,
    descriptionsBox: descriptionsBox,
  );
  getIt.registerSingleton<AssetLocalSource>(localSource);

  final remoteSource = LookupRemoteSourceImpl(dio: dio);
  getIt.registerSingleton<LookupRemoteSource>(remoteSource);

  // Repository
  final repository = AssetRepositoryImpl(
    localSource: localSource,
    remoteSource: remoteSource,
    connectivityService: ConnectivityService.instance,
  );
  getIt.registerSingleton<AssetRepository>(repository);

  // Use Cases
  getIt.registerSingleton<FetchLookupsUseCase>(
    FetchLookupsUseCase(repository: repository),
  );
  getIt.registerSingleton<SaveAssetUseCase>(
    SaveAssetUseCase(repository: repository),
  );
  getIt.registerSingleton<AddLookupItemUseCase>(
    AddLookupItemUseCase(repository: repository),
  );
}
