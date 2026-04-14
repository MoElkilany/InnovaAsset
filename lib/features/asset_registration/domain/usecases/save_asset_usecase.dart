import 'package:innova/core/error/failures.dart';
import 'package:innova/features/asset_registration/data/models/asset_model.dart';
import 'package:innova/features/asset_registration/domain/repositories/asset_repository.dart';

/// Use case for saving an asset to local storage.
class SaveAssetUseCase {
  final AssetRepository _repository;

  SaveAssetUseCase({required AssetRepository repository})
      : _repository = repository;

  Future<(Failure?, void)> call(AssetModel asset) async {
    return _repository.saveAsset(asset);
  }
}
