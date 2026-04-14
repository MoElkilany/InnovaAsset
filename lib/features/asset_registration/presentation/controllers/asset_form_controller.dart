import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:innova/features/asset_registration/data/models/asset_description_model.dart';
import 'package:innova/features/asset_registration/data/models/asset_model.dart';
import 'package:innova/features/asset_registration/data/models/category_model.dart';
import 'package:innova/features/asset_registration/data/models/location_model.dart';
import 'package:innova/features/asset_registration/domain/usecases/add_lookup_item_usecase.dart';
import 'package:innova/features/asset_registration/domain/usecases/fetch_lookups_usecase.dart';
import 'package:innova/features/asset_registration/domain/usecases/save_asset_usecase.dart';
import 'package:uuid/uuid.dart';

class AssetFormState {
  // Lookup data
  final List<CategoryModel> categories;
  final List<LocationModel> locations;
  final List<AssetDescriptionModel> descriptions;

  // Loading states
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool saveSuccess;

  // Form field values
  final String? selectedDescriptionId;
  final String? assetCode;
  final String? selectedCategoryId;
  final String? selectedLocationId;
  final String? selectedStatus;
  final String? assetDetails;
  final String? imagePath;

  // Validation errors
  final Map<String, String?> fieldErrors;

  const AssetFormState({
    this.categories = const [],
    this.locations = const [],
    this.descriptions = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.saveSuccess = false,
    this.selectedDescriptionId,
    this.assetCode,
    this.selectedCategoryId,
    this.selectedLocationId,
    this.selectedStatus,
    this.assetDetails,
    this.imagePath,
    this.fieldErrors = const {},
  });

  AssetFormState copyWith({
    List<CategoryModel>? categories,
    List<LocationModel>? locations,
    List<AssetDescriptionModel>? descriptions,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? saveSuccess,
    String? selectedDescriptionId,
    String? assetCode,
    String? selectedCategoryId,
    String? selectedLocationId,
    String? selectedStatus,
    String? assetDetails,
    String? imagePath,
    Map<String, String?>? fieldErrors,
  }) {
    return AssetFormState(
      categories: categories ?? this.categories,
      locations: locations ?? this.locations,
      descriptions: descriptions ?? this.descriptions,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      selectedDescriptionId:
          selectedDescriptionId ?? this.selectedDescriptionId,
      assetCode: assetCode ?? this.assetCode,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      assetDetails: assetDetails ?? this.assetDetails,
      imagePath: imagePath ?? this.imagePath,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class AssetFormController extends ChangeNotifier {
  final FetchLookupsUseCase _fetchLookupsUseCase;
  final SaveAssetUseCase _saveAssetUseCase;
  final AddLookupItemUseCase _addLookupItemUseCase;
  final ImagePicker _imagePicker;

  AssetFormController({
    required FetchLookupsUseCase fetchLookupsUseCase,
    required SaveAssetUseCase saveAssetUseCase,
    required AddLookupItemUseCase addLookupItemUseCase,
    ImagePicker? imagePicker,
  })  : _fetchLookupsUseCase = fetchLookupsUseCase,
        _saveAssetUseCase = saveAssetUseCase,
        _addLookupItemUseCase = addLookupItemUseCase,
        _imagePicker = imagePicker ?? ImagePicker();

  final ValueNotifier<AssetFormState> _stateNotifier =
      ValueNotifier(const AssetFormState());

  ValueNotifier<AssetFormState> get stateNotifier => _stateNotifier;

  AssetFormState get state => _stateNotifier.value;

  /// Loads all lookup data (categories, locations, descriptions).
  Future<void> loadLookups() async {
    _stateNotifier.value = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _fetchLookupsUseCase();

    if (result.$1 != null) {
      _stateNotifier.value = state.copyWith(
        isLoading: false,
        errorMessage: result.$1?.message ?? 'Failed to load data',
      );
    } else {
      _stateNotifier.value = state.copyWith(
        isLoading: false,
        categories: result.$2?.categories ?? [],
        locations: result.$2?.locations ?? [],
        descriptions: result.$2?.descriptions ?? [],
      );
    }
  }

  /// Adds a new lookup item and refreshes the list.
  Future<void> addLookupItem(LookupType type, String name) async {
    final result = await _addLookupItemUseCase(type, name);

    if (result.$1 != null) {
      _stateNotifier.value = state.copyWith(
        errorMessage: result.$1?.message ?? 'Failed to add item',
      );
    } else {
      // Reload the specific list based on type
      await _reloadLookupsByType(type);
    }
  }

  /// Reloads a specific lookup list.
  Future<void> _reloadLookupsByType(LookupType type) async {
    await loadLookups();
  }

  /// Sets a form field value and clears its error.
  void setField(String fieldKey, dynamic value) {
    final fieldErrors = Map<String, String?>.from(state.fieldErrors);
    fieldErrors[fieldKey] = null;

    switch (fieldKey) {
      case 'description':
        _stateNotifier.value = state.copyWith(
          selectedDescriptionId: value as String?,
          fieldErrors: fieldErrors,
        );
      case 'code':
        _stateNotifier.value = state.copyWith(
          assetCode: value as String?,
          fieldErrors: fieldErrors,
        );
      case 'category':
        _stateNotifier.value = state.copyWith(
          selectedCategoryId: value as String?,
          fieldErrors: fieldErrors,
        );
      case 'location':
        _stateNotifier.value = state.copyWith(
          selectedLocationId: value as String?,
          fieldErrors: fieldErrors,
        );
      case 'status':
        _stateNotifier.value = state.copyWith(
          selectedStatus: value as String?,
          fieldErrors: fieldErrors,
        );
      case 'details':
        _stateNotifier.value = state.copyWith(
          assetDetails: value as String?,
          fieldErrors: fieldErrors,
        );
      case 'image':
        _stateNotifier.value = state.copyWith(
          imagePath: value as String?,
          fieldErrors: fieldErrors,
        );
    }
  }

  /// Picks an image from camera or gallery.
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setField('image', pickedFile.path);
      }
    } catch (e) {
      _stateNotifier.value = state.copyWith(
        errorMessage: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  /// Scans a QR code and sets the asset code.
  Future<String?> scanQrCode() async {
    // This will be implemented in a separate screen/dialog
    // For now, return null to allow the screen to handle it
    return null;
  }

  /// Sets the scanned QR code as asset code.
  void setScannedCode(String code) {
    setField('code', code);
  }

  /// Validates all required fields.
  Map<String, String?> _validate() {
    final errors = <String, String?>{};

    if ((state.selectedDescriptionId ?? '').isEmpty) {
      errors['description'] = 'This field is required';
    }
    if ((state.assetCode ?? '').isEmpty) {
      errors['code'] = 'This field is required';
    }
    if ((state.selectedCategoryId ?? '').isEmpty) {
      errors['category'] = 'This field is required';
    }
    if ((state.selectedLocationId ?? '').isEmpty) {
      errors['location'] = 'This field is required';
    }
    if ((state.selectedStatus ?? '').isEmpty) {
      errors['status'] = 'This field is required';
    }
    if ((state.assetDetails ?? '').isEmpty) {
      errors['details'] = 'This field is required';
    }
    if ((state.imagePath ?? '').isEmpty) {
      errors['image'] = 'This field is required';
    }

    return errors;
  }

  /// Submits the form and saves the asset.
  Future<void> submitForm() async {
    // Validate
    final errors = _validate();
    if (errors.isNotEmpty) {
      _stateNotifier.value = state.copyWith(fieldErrors: errors);
      return;
    }

    _stateNotifier.value = state.copyWith(
      isSaving: true,
      errorMessage: null,
      saveSuccess: false,
    );

    final asset = AssetModel(
      id: const Uuid().v4(),
      descriptionId: state.selectedDescriptionId ?? '',
      code: state.assetCode ?? '',
      categoryId: state.selectedCategoryId ?? '',
      locationId: state.selectedLocationId ?? '',
      status: state.selectedStatus ?? '',
      details: state.assetDetails ?? '',
      imagePath: state.imagePath ?? '',
      createdAt: DateTime.now(),
      isSynced: false,
    );

    final result = await _saveAssetUseCase(asset);

    if (result.$1 != null) {
      _stateNotifier.value = state.copyWith(
        isSaving: false,
        errorMessage: result.$1?.message ?? 'Failed to save asset',
      );
    } else {
      _stateNotifier.value = state.copyWith(
        isSaving: false,
        saveSuccess: true,
        errorMessage: null,
      );
    }
  }

  /// Clears the form and resets to initial state.
  void resetForm() {
    _stateNotifier.value = const AssetFormState();
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }
}
