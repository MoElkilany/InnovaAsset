import 'package:flutter/material.dart';
import 'package:innova/core/di/service_locator.dart';
import 'package:innova/features/asset_registration/domain/usecases/add_lookup_item_usecase.dart';
import 'package:innova/features/webview/webview_screen.dart';
import 'package:innova/features/asset_registration/presentation/controllers/asset_form_controller.dart';
import 'package:innova/features/asset_registration/presentation/screens/qr_scanner_screen.dart';
import 'package:innova/features/asset_registration/presentation/widgets/asset_code_field.dart';
import 'package:innova/features/asset_registration/presentation/widgets/asset_image_picker.dart';
import 'package:innova/features/asset_registration/presentation/widgets/lookup_dropdown_field.dart';

/// Main asset registration form screen for offline mode.
class AssetFormScreen extends StatefulWidget {
  const AssetFormScreen({super.key});

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  late AssetFormController _controller;

  static const List<String> _statusOptions = [
    'Available',
    'In Use',
    'Under Maintenance',
    'Retired',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AssetFormController(
      fetchLookupsUseCase: getIt(),
      saveAssetUseCase: getIt(),
      addLookupItemUseCase: getIt(),
    );
    _controller.loadLookups();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, LookupType type) {
    final textController = TextEditingController();
    final typeLabel = switch (type) {
      LookupType.category => 'Category',
      LookupType.location => 'Location',
      LookupType.description => 'Description',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $typeLabel'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: typeLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _controller.addLookupItem(type, textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
    if (result != null) {
      _controller.setScannedCode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Asset (Offline)'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const WebViewScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud, size: 18),
                label: const Text('Online'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<AssetFormState>(
        valueListenable: _controller.stateNotifier,
        builder: (context, state, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (state.errorMessage != null && !state.saveSuccess)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style:
                                    Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (state.errorMessage != null && !state.saveSuccess)
                      const SizedBox(height: 16),

                    // Success message
                    if (state.saveSuccess)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Asset saved successfully!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.green,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (state.saveSuccess) const SizedBox(height: 16),

                    // Form Section Header
                    _buildSectionHeader(context, 'Asset Information'),
                    const SizedBox(height: 16),

                    // Asset Description
                    LookupDropdownField<dynamic>(
                      label: 'Asset Description *',
                      items: state.descriptions,
                      selectedValue: state.selectedDescriptionId,
                      errorMessage: state.fieldErrors['description'],
                      onChanged: (value) =>
                          _controller.setField('description', value),
                      onAddNew: () =>
                          _showAddDialog(context, LookupType.description),
                      getItemId: (item) => item.id,
                      getItemLabel: (item) => item.label,
                    ),
                    const SizedBox(height: 16),

                    // Asset Code with QR
                    AssetCodeField(
                      value: state.assetCode,
                      errorMessage: state.fieldErrors['code'],
                      onChanged: (value) => _controller.setField('code', value),
                      onScan: _scanQRCode,
                    ),
                    const SizedBox(height: 16),

                    // Category
                    LookupDropdownField<dynamic>(
                      label: 'Category *',
                      items: state.categories,
                      selectedValue: state.selectedCategoryId,
                      errorMessage: state.fieldErrors['category'],
                      onChanged: (value) =>
                          _controller.setField('category', value),
                      onAddNew: () =>
                          _showAddDialog(context, LookupType.category),
                      getItemId: (item) => item.id,
                      getItemLabel: (item) => item.name,
                    ),
                    const SizedBox(height: 16),

                    // Location
                    LookupDropdownField<dynamic>(
                      label: 'Location *',
                      items: state.locations,
                      selectedValue: state.selectedLocationId,
                      errorMessage: state.fieldErrors['location'],
                      onChanged: (value) =>
                          _controller.setField('location', value),
                      onAddNew: () =>
                          _showAddDialog(context, LookupType.location),
                      getItemId: (item) => item.id,
                      getItemLabel: (item) => item.name,
                    ),
                    const SizedBox(height: 16),

                    // Status
                    _buildStatusDropdown(context, state),
                    const SizedBox(height: 16),

                    // Details Section Header
                    _buildSectionHeader(context, 'Details'),
                    const SizedBox(height: 16),

                    // Asset Details Text Area
                    _buildDetailsTextArea(context, state),
                    const SizedBox(height: 16),

                    // Image Section Header
                    _buildSectionHeader(context, 'Asset Image'),
                    const SizedBox(height: 16),

                    // Asset Image Picker
                    AssetImagePicker(
                      imagePath: state.imagePath,
                      errorMessage: state.fieldErrors['image'],
                      onPick: _controller.pickImage,
                      onClear: () => _controller.setField('image', null),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isSaving
                            ? null
                            : _controller.submitForm,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: state.isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Submit'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Switch to Online Mode Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const WebViewScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.cloud),
                        label: const Text('Switch to Online Mode'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Loading overlay
              if (state.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, AssetFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: state.fieldErrors['status'] != null
                  ? Theme.of(context).colorScheme.error
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: state.selectedStatus,
            items: _statusOptions
                .map((status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) => _controller.setField('status', value),
            isExpanded: true,
            hint: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Select Status'),
            ),
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        if (state.fieldErrors['status'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.fieldErrors['status']!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsTextArea(BuildContext context, AssetFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter basic details for your asset *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: state.fieldErrors['details'] != null
                  ? Theme.of(context).colorScheme.error
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            maxLines: 5,
            maxLength: 1000,
            onChanged: (value) => _controller.setField('details', value),
            decoration: const InputDecoration(
              hintText: 'Enter asset details',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              counterText: '',
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${state.assetDetails?.length ?? 0}/1000',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ),
        if (state.fieldErrors['details'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.fieldErrors['details']!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
