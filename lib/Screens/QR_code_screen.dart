import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:team_project/Controllers/QrScannerController.dart';
import 'package:team_project/Screens/Home_Screen.dart';

class QrScannerScreen extends StatelessWidget {
  // Inject the GetX controller
  final QrScannerController controller = Get.put(QrScannerController());

  QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Apply a specific dark theme for the scanner screen
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        // Define theme for GetX SnackBar
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF333333),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Scan your QR',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: InkWell(
            onTap: () {
              // Navigate back to the home screen
              Get.off(()=> const HomeScreen()); 
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
          actions: [
            // Button to re-open the last scanned link's snackbar
            Obx(() => IconButton(
                  icon: Icon(
                    controller.scannedUrl.isNotEmpty
                        ? Icons.link_rounded
                        : Icons.link_off_rounded,
                    color: controller.scannedUrl.isNotEmpty
                        ? Colors.lightGreenAccent
                        : Colors.grey,
                  ),
                  onPressed: () {
                    if (controller.scannedUrl.isNotEmpty) {
                      controller.showUrlSnackbar(controller.scannedUrl.value);
                    } else {
                      Get.snackbar(
                        'No Code Scanned',
                        'Point the camera at a QR code to scan a link.',
                        backgroundColor: const Color(0xFF333333),
                        colorText: Colors.white70,
                      );
                    }
                  },
                )),
          ],
        ),
        body: Stack(
          children: [
            // 1. The Mobile Scanner Widget (Full Screen)
            MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal, 
                detectionTimeoutMs: 500, 
              ),
              onDetect: controller.onQrCodeScanned,
              // ERROR FIXED: Only two arguments (context, error) are used here.
              errorBuilder: (context, error) { 
                return Center(
                  child: Text(
                    'Error loading camera: ${error.toString()}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            // 2. Custom Scanning Overlay (Visual guide)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF4CAF50), // Distinct green border
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Scan a QR Code',
                      style: TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}