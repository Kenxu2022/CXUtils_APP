import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isInitializing = true;
  String? _capturedImagePath;
  bool _isTakingPicture = false;

  Future<void> _showCameraInitErrorDialog(String reason) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('相机启动失败'),
          content: Text(reason),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        await _showCameraInitErrorDialog('未检测到可用相机设备。');
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      final controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            await _showCameraInitErrorDialog('未授予相机权限，请在系统设置中开启后重试。');
            break;
          default:
            await _showCameraInitErrorDialog(
              e.description ?? '未知错误：${e.code}',
            );
            break;
        }
      } else {
        await _showCameraInitErrorDialog('未知错误：$e');
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (_isTakingPicture || controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile photo = await controller.takePicture();
      if (!mounted) {
        return;
      }
      setState(() {
        _capturedImagePath = photo.path;
      });
    } on CameraException {
      // Keep current UI state when taking picture fails.
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  Widget _buildPreviewArea() {
    if (_capturedImagePath != null) {
      return Image.file(
        File(_capturedImagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    final controller = _controller;
    if (_isInitializing || controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(controller);
  }

  Widget _buildShutterButton() {
    final controller = _controller;
    final bool disabled =
        _isTakingPicture || controller == null || !controller.value.isInitialized;

    return InkWell(
      onTap: disabled ? null : _takePicture,
      borderRadius: BorderRadius.circular(48),
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Container(
          width: 78,
          height: 78,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拍摄图片')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 85,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    color: Colors.black12,
                    child: _buildPreviewArea(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 15,
                child: _capturedImagePath == null
                    ? Center(child: _buildShutterButton())
                    : Row(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: IconButton.filledTonal(
                                onPressed: () {
                                  setState(() {
                                    _capturedImagePath = null;
                                  });
                                },
                                iconSize: 45,
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: IconButton.filledTonal(
                                onPressed: () {
                                  final imagePath = _capturedImagePath;
                                  if (imagePath == null || imagePath.isEmpty) {
                                    return;
                                  }
                                  Navigator.of(context).pop(imagePath);
                                },
                                iconSize: 45,
                                icon: const Icon(Icons.check_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}