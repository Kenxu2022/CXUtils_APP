import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrcodeScanningPage extends StatefulWidget {
  const QrcodeScanningPage({super.key});

  @override
  State<QrcodeScanningPage> createState() => _QrcodeScanningPageState();
}

class _QrcodeScanningPageState extends State<QrcodeScanningPage> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    for (final b in barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      final uri = Uri.tryParse(raw);
      if (uri != null) {
        final enc = uri.queryParameters['enc'];
        if (enc != null && enc.isNotEmpty) {
          _handled = true;
          Navigator.of(context).pop(enc);
          return;
        }
      }
    }
    // 未识别到 enc，给出轻提示但继续扫描
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('未识别到 enc 参数，请对准学习通签到二维码'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码签到')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '请扫描签到二维码',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: MobileScanner(onDetect: _onDetect),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
