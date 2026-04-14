import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Screen for scanning QR codes.
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (barcodes.barcodes.isNotEmpty) {
      final barcode = barcodes.barcodes.first;
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        Navigator.of(context).pop(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        centerTitle: true,
        elevation: 0,
      ),
      body: MobileScanner(
        controller: _cameraController,
        onDetect: _handleBarcode,
        errorBuilder: (context, error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  error.errorDetails?.message ?? 'Camera permission required',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please enable camera access in settings',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
