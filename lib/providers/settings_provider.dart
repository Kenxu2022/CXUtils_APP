import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static SettingsProvider? _instance;
  late SharedPreferences _prefs;
  ThemeMode _themeValue = ThemeMode.system;
  String _endpoint = "";
  String _username = "";
  String _password = "";
  String _latitude = "";
  String _longitude = "";
  String _locationText = "";
  String _overrideCourseID = "";
  String _overrideClassID = "";
  bool _isInitializationFinished = false;
  bool _isInitialized = false;

  SettingsProvider._() {
    _init();
  }

  static SettingsProvider get instance {
    _instance ??= SettingsProvider._();
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final int? themeInt = _prefs.getInt('theme');
    final String? endpoint = _prefs.getString('endpoint');
    final String? username = _prefs.getString('username');
    final String? password = _prefs.getString('password');
    final String? latitude = _prefs.getString('latitude');
    final String? longitude = _prefs.getString('longitude');
    final String? locationText = _prefs.getString('locationText');
    final String? overrideCourseID = _prefs.getString('overrideCourseID');
    final String? overrideClassID = _prefs.getString('overrideClassID');
    _isInitializationFinished = _prefs.getBool('isInitializationFinished') ?? false;
    _themeValue =
        themeInt == 0
            ? ThemeMode.light
            : themeInt == 1
            ? ThemeMode.dark
            : ThemeMode.system;
    _endpoint = endpoint ?? "";
    _username = username ?? "";
    _password = password ?? "";
    _latitude = latitude ?? "";
    _longitude = longitude ?? "";
    _locationText = locationText ?? "";
    _overrideCourseID = overrideCourseID ?? "";
    _overrideClassID = overrideClassID ?? "";
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;
  bool get isInitializationFinished => _isInitializationFinished;

  ThemeMode get themeValue => _themeValue;
  String get endpoint => _endpoint;
  String get username => _username;
  String get password => _password;
  String get latitude => _latitude;
  String get longitude => _longitude;
  String get locationText => _locationText;
  String get overrideCourseID => _overrideCourseID;
  String get overrideClassID => _overrideClassID;

  Future<void> setInitializationFinished(bool value) async {
    _isInitializationFinished = value;
    await _prefs.setBool('isInitializationFinished', value);
    notifyListeners();
  }

  Future<void> setThemeValue(ThemeMode value) async {
    _themeValue = value;
    await (_themeValue == ThemeMode.light
        ? _prefs.setInt('theme', 0)
        : _themeValue == ThemeMode.dark
        ? _prefs.setInt('theme', 1)
        : _prefs.setInt('theme', 2));
    notifyListeners();
  }

  Future<void> setEndpointValue(String value) async {
    _endpoint = value;
    _prefs.setString('endpoint', value);
    notifyListeners();
  }

  Future<void> setUsername(String value) async {
    _username = value;
    _prefs.setString('username', value);
    notifyListeners();
  }

  Future<void> setPassword(String value) async {
    _password = value;
    _prefs.setString('password', value);
    notifyListeners();
  }

  Future<void> setLatitude(String value) async {
    _latitude = value;
    _prefs.setString('latitude', value);
    notifyListeners();
  }

  Future<void> setLongitude(String value) async {
    _longitude = value;
    _prefs.setString('longitude', value);
    notifyListeners();
  }

  Future<void> setLocationText(String value) async {
    _locationText = value;
    _prefs.setString('locationText', value);
    notifyListeners();
  }

  Future<void> setOverrideCourseID(String value) async {
    _overrideCourseID = value;
    _prefs.setString('overrideCourseID', value);
    notifyListeners();
  }

  Future<void> setOverrideClassID(String value) async {
    _overrideClassID = value;
    _prefs.setString('overrideClassID', value);
    notifyListeners();
  }

  Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
