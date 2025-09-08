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

  bool get _isFormComplete =>
      _latitudeController.text.isNotEmpty &&
      _longitudeController.text.isNotEmpty &&
      _locationTextController.text.isNotEmpty;

  Future<void> _saveAndFinish() async {
    if (_isFormComplete) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      await settings.setLatitude(_latitudeController.text);
      await settings.setLongitude(_longitudeController.text);
      await settings.setLocationText(_locationTextController.text);
      await settings.setInitializationFinished(true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('纬度'),
                  trailing: SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _latitudeController,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '请输入纬度',
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('经度'),
                  trailing: SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _longitudeController,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '请输入经度',
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('位置显示文字'),
                  trailing: SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _locationTextController,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '请输入位置文字',
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isFormComplete ? _saveAndFinish : null,
              child: const Text('完成'),
            ),
          ),
        ],
      ),
    );
  }
}
