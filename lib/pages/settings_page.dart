import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cxutils/pages/settings_page_dialog.dart';
import 'package:cxutils/providers/credentials_provider.dart';
import 'package:cxutils/providers/settings_provider.dart';
import 'package:cxutils/utils/sync_logic.dart';

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

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final credentialsProvider = Provider.of<CredentialsProvider>(context, listen: false);
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
                "账号",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text("同步账号信息", style: TextStyle(fontSize: 16)),
              subtitle: Text("将服务端已存在的账号同步至本地"),
              trailing: ElevatedButton(
                onPressed: () async {
                  await syncUsersFromServer(
                    context: context,
                    credentialsProvider: credentialsProvider,
                    showErrorDialog: showSyncUsersErrorDialog,
                    showConfirmDialog: showSyncUsersConfirmDialog,
                  );
                },
                child: const Text('同步'),
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
              title: Text("生成配置二维码", style: TextStyle(fontSize: 16)),
              subtitle: Text("包含后端账号密码和签到定位等信息，可在新设备上扫码导入"),
              trailing: ElevatedButton(
                onPressed: () async {
                  await showQRCodeDialog(
                    context,
                    settingsProvider,
                    credentialsProvider,
                  );
                },
                child: const Text('生成'),
              ),
            ),
            SizedBox(height: 4),
            ListTile(
              title: Text("修改位置信息", style: TextStyle(fontSize: 16)),
              trailing: ElevatedButton(
                onPressed: () async {
                  await showLocationDialog(context, settingsProvider);
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
              title: Text("强制指定课程信息", style: TextStyle(fontSize: 16)),
              subtitle: Text("仅供调试使用，正常使用请勿设置"),
              trailing: ElevatedButton(
                onPressed: () async {
                  await showOverrideDialog(context, settingsProvider);
                },
                child: const Text('设置'),
              ),
            ),
            SizedBox(height: 4),
            ListTile(
              title: Text("清除所有数据", style: TextStyle(fontSize: 16)),
              subtitle: Text("重置所有设置，重启生效"),
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
              child: Text("CXUtils", style: TextStyle(fontSize: 16)),
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
