import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrcodeScanningPage extends StatefulWidget {
  const QrcodeScanningPage({super.key});

  @override
  State<QrcodeScanningPage> createState() => _QrcodeScanningPageState();
}

class _QrcodeScanningPageState extends State<QrcodeScanningPage> {
  final MobileScannerController controller = MobileScannerController(
    autoZoom: true,
  );
  bool _handled = false;
  double _baseZoom = 0.0;
  bool _baseZoomCaptured = false;
  double _currentZoom = 0.0;
  double _startZoom = 0.0;
  bool _isScaling = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final state = controller.value;
    if (!_baseZoomCaptured && state.isInitialized) {
      _baseZoomCaptured = true;
      _baseZoom = state.zoomScale;
      _currentZoom = _baseZoom;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    super.dispose();
  }

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
              const SizedBox(height: 8),
              const Text(
                '支持双指捏合缩放',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () {
                    final isAtBase = (_currentZoom - _baseZoom).abs() < 1e-3;
                    final target = isAtBase
                        ? (_baseZoom + 0.3)
                        : _baseZoom;
                    _currentZoom = target;
                    controller.setZoomScale(_currentZoom);
                  },
                  onScaleStart: (details) {
                    if (details.pointerCount >= 2) {
                      _isScaling = true;
                      _startZoom = controller.value.zoomScale;
                    }
                  },
                  onScaleUpdate: (details) {
                    if (!_isScaling || details.pointerCount < 2) return;
                    final delta = details.scale - 1.0;
                    final next = (_startZoom + delta);
                    if ((next - _currentZoom).abs() >= 1e-3) {
                      _currentZoom = next;
                      controller.setZoomScale(_currentZoom);
                    }
                  },
                  onScaleEnd: (details) {
                    _isScaling = false;
                    _currentZoom = controller.value.zoomScale;
                  },
                  child: SizedBox(
                    width: 350,
                    height: 350,
                    child: MobileScanner(
                      controller: controller,
                      onDetect: _onDetect,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
