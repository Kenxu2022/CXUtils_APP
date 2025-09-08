import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionSettingsPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const PermissionSettingsPage({super.key, required this.onSuccess});

  @override
  State<PermissionSettingsPage> createState() => _PermissionSettingsPageState();
}

class _PermissionSettingsPageState extends State<PermissionSettingsPage> {
  bool _isGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _isGranted = true;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isGranted = true;
      });
    } else {
      // Handle permission denied case
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('摄像头权限被拒绝')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('权限设置'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '扫码阶段需调用系统摄像头，请同意摄像头权限',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_isGranted)
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: const Text('授权'),
                )
              else
                ElevatedButton(
                  onPressed: widget.onSuccess,
                  child: const Text('下一步'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
