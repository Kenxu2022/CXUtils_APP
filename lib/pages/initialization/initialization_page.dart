import 'package:flutter/material.dart';
import 'package:cxutils/pages/initialization/backend_settings_page.dart';
import 'package:cxutils/pages/initialization/permission_settings_page.dart';
import 'package:cxutils/pages/initialization/info_settings_page.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({super.key});

  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe gesture
        children: [
          BackendSettingsPage(onSuccess: _nextPage),
          PermissionSettingsPage(onSuccess: _nextPage),
          const InfoSettingsPage(),
        ],
      ),
    );
  }
}
