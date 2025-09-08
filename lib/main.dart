import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cxutils/providers/settings_provider.dart';
import 'package:cxutils/pages/home/home_page.dart';
import 'package:cxutils/pages/initialization/initialization_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider.instance,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'CXUtils',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: settings.themeValue,
          home: Builder(
            builder: (context) {
              if (!settings.isInitialized) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return settings.isInitializationFinished
                  ? const HomePage()
                  : const InitializationPage();
            },
          ),
        );
      },
    );
  }
}
