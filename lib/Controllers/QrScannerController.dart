import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Required for BarcodeCapture/Barcode
import 'package:url_launcher/url_launcher.dart'; // <<< CRITICAL IMPORT FOR URL HANDLING

class QrScannerController extends GetxController {
  // Observables for state management
  final RxString scannedUrl = ''.obs;

  // --- Core Scanning Logic ---
  void onQrCodeScanned(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty) {
      // Use displayValue which often includes the protocol (http/https)
      final String? url = barcodes.first.displayValue; 

      // Check if the URL is valid and hasn't been scanned recently
      if (url != null && url.isNotEmpty && url != scannedUrl.value) {
        // Update the reactive URL state
        scannedUrl.value = url;
        
        // Show the actionable snackbar
        showUrlSnackbar(url);
      }
    }
  }

  // --- UI/Action Logic ---
  void showUrlSnackbar(String url) {
    Get.snackbar(
      'QR Code Scanned! 🤩',
      url,
      snackPosition: SnackPosition.BOTTOM,
      // Using custom dark theme colors defined in the screen
      backgroundColor: const Color(0xFF333333), 
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
      mainButton: TextButton(
        onPressed: () {
          // Close the snackbar before launching the URL
          if (Get.isSnackbarOpen) {
            Get.back();
          }
          openUrlInBrowser(url);
        },
        child: const Text(
          'OPEN LINK',
          style: TextStyle(
            color: Color(0xFF4CAF50), // Green for action
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void openUrlInBrowser(String url) async {
    // 1. Robustly ensure the URL has a protocol (http/https) for safe launching
    String launchUrlString = url;
    if (!url.startsWith('http://') && !url.startsWith('https://') && url.contains('.')) {
        launchUrlString = 'https://$url';
    }

    final Uri uri = Uri.parse(launchUrlString);

    if (await canLaunchUrl(uri)) {
      // Launch the URL in the default browser (Chrome/Safari, etc.)
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open link: $url',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF333333),
        colorText: const Color(0xFFF44336), // Red error color
      );
    }
  }
}