import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cxutils/providers/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<DropdownMenuEntry<dynamic>> themeChoices = [
    DropdownMenuEntry(value: ThemeMode.light, label: "亮色"),
    DropdownMenuEntry(value: ThemeMode.dark, label: "暗色"),
    DropdownMenuEntry(value: ThemeMode.system, label: "系统"),
  ];
  // PackageInfo? packageInfo;
  String versionText = "Loading...";

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        versionText = "Version: ${info.version} (${info.buildNumber})";
      });
    }
  }

  Future<void> _showLocationDialog() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final latitudeController =
        TextEditingController(text: settingsProvider.latitude);
    final longitudeController =
        TextEditingController(text: settingsProvider.longitude);
    final locationTextController =
        TextEditingController(text: settingsProvider.locationText);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('修改位置信息'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: latitudeController,
                  decoration: const InputDecoration(
                    labelText: '纬度',
                    hintText: '例如: 39.90923',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: longitudeController,
                  decoration: const InputDecoration(
                    labelText: '经度',
                    hintText: '例如: 116.397428',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: locationTextController,
                  decoration: const InputDecoration(
                    labelText: '位置名称',
                    hintText: '例如: 天安门广场',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () async {
                await settingsProvider.setLatitude(latitudeController.text);
                await settingsProvider.setLongitude(longitudeController.text);
                await settingsProvider
                    .setLocationText(locationTextController.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 48,
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "常规",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text("主题", style: TextStyle(fontSize: 16)),
              trailing: DropdownMenu(
                initialSelection: settingsProvider.themeValue,
                dropdownMenuEntries: themeChoices,
                onSelected: (value) async {
                  await settingsProvider.setThemeValue(value);
                },
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "签到",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text("修改位置信息", style: TextStyle(fontSize: 16)),
              trailing: ElevatedButton(
                onPressed: () {
                  _showLocationDialog();
                },
                child: const Text('修改'),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "高级",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text("清除所有数据", style: TextStyle(fontSize: 16)),
              subtitle: Text("将清除对话记录并重置所有设置，重启生效"),
              trailing: IconButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await settingsProvider.clearPrefs();
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("已清除，请重启应用")));
                  }
                },
                icon: Icon(Icons.delete_forever_rounded),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "关于",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                "CXUtils",
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(versionText, style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
