import 'package:bettingapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  final void Function(String ticket) onScanned;
  final String? title;

  const QrScannerPage({Key? key, required this.onScanned, this.title}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(widget.title ?? 'Scan Ticket QR'),
        leading: IconButton(
          onPressed: () =>Get.back(),
          icon: Icon(Icons.arrow_back,color: Colors.white,),
        ),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final String? code = capture.barcodes.firstOrNull?.rawValue;
          if (code != null && !_scanned) {
            _scanned = true;
            widget.onScanned(code);
            Get.back();
          }
        },
      ),
     
    );
  }
} 