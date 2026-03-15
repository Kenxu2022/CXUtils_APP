import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialsProvider extends ChangeNotifier {
  static CredentialsProvider? _instance;
  late SharedPreferences _prefs;
  List<String> _credentials = [];
  List<String> _nicknames = [];
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
    final List<String>? nicknames = _prefs.getStringList('nicknames');
    _nicknames = nicknames ?? [];
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  List<String> get credentials => _credentials;

  List<String> get nicknames => _nicknames;

  Future<void> addUser(String user, String nickname) async {
    final int existingIndex = _credentials.indexOf(user);
    if (existingIndex != -1) {
      if (existingIndex < _nicknames.length) {
        _nicknames[existingIndex] = nickname;
      } else {
        _nicknames.insert(existingIndex, nickname);
      }
    } else {
      final int insertIndex = _credentials.length;
      _credentials.add(user);
      _nicknames.insert(insertIndex, nickname);
    }
    await _prefs.setStringList('credentials', _credentials);
    await _prefs.setStringList('nicknames', _nicknames);
    notifyListeners();
  }

  Future<void> removeUser(String user) async {
    final int index = _credentials.indexOf(user);
    _credentials.removeAt(index);
    _nicknames.removeAt(index);
    await _prefs.setStringList('credentials', _credentials);
    await _prefs.setStringList('nicknames', _nicknames);
    notifyListeners();
  }
}
