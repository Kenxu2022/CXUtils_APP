import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialsProvider extends ChangeNotifier {
  static CredentialsProvider? _instance;
  late SharedPreferences _prefs;
  List<String> _credentials = [];
  bool _isInitialized = false;

  CredentialsProvider._() {
    _init();
  }

  static CredentialsProvider get instance {
    _instance ??= CredentialsProvider._();
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String>? credentials = _prefs.getStringList('credentials');
    _credentials = credentials ?? [];
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  List<String> get credentials => _credentials;

  Future<void> addUser(String user) async {
    _credentials.add(user);
    await _prefs.setStringList('credentials', _credentials);
    notifyListeners();
  }

  Future<void> removeUser(String user) async {
    _credentials.remove(user);
    await _prefs.setStringList('credentials', _credentials);
    notifyListeners();
  }
}
