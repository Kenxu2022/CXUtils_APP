import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cxutils/providers/settings_provider.dart';
import 'package:cxutils/pages/home/home_page.dart';

class InfoSettingsPage extends StatefulWidget {
  const InfoSettingsPage({super.key});

  @override
  State<InfoSettingsPage> createState() => _InfoSettingsPageState();
}

class _InfoSettingsPageState extends State<InfoSettingsPage> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _locationTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _latitudeController.text = settings.latitude;
    _longitudeController.text = settings.longitude;
    _locationTextController.text = settings.locationText;
  }

  bool get _isLatitudeValid =>
      _latitudeController.text.isEmpty ||
      double.tryParse(_latitudeController.text) != null;
  bool get _isLongitudeValid =>
      _longitudeController.text.isEmpty ||
      double.tryParse(_longitudeController.text) != null;

  bool get _isFormComplete =>
      _latitudeController.text.isNotEmpty &&
      double.tryParse(_latitudeController.text) != null &&
      _longitudeController.text.isNotEmpty &&
      double.tryParse(_longitudeController.text) != null &&
      _locationTextController.text.isNotEmpty;

  Future<void> _saveAndFinish() async {
    if (_isFormComplete) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      await settings.setLatitude(_latitudeController.text);
      await settings.setLongitude(_longitudeController.text);
      await settings.setLocationText(_locationTextController.text);
      await settings.setInitializationFinished(true);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有信息')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('信息设置'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _latitudeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '纬度',
                  border: const OutlineInputBorder(),
                  errorText: _isLatitudeValid ? null : '请输入有效的数字',
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _longitudeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '经度',
                  border: const OutlineInputBorder(),
                  errorText: _isLongitudeValid ? null : '请输入有效的数字',
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationTextController,
                decoration: const InputDecoration(
                  hintText: '位置显示文字',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isFormComplete ? _saveAndFinish : null,
                child: const Text('完成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
