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
    if (_nicknames.length < _credentials.length) {
      _nicknames.addAll(List.filled(_credentials.length - _nicknames.length, ''));
    }
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  List<String> get credentials => _credentials;

  List<String> get nicknames => _nicknames;

  Future<void> addUser(String user, String nickname) async {
    final int index = _credentials.indexOf(user);
    if (index != -1) {
      _nicknames[index] = nickname;
    } else {
      _credentials.add(user);
      _nicknames.add(nickname);
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

  Future<void> setUsers(List<String> credentials, List<String> nicknames) async {
    _credentials = List<String>.from(credentials);
    _nicknames = List<String>.from(nicknames);
    if (_nicknames.length < _credentials.length) {
      _nicknames.addAll(List.filled(_credentials.length - _nicknames.length, ''));
    } else if (_nicknames.length > _credentials.length) {
      _nicknames = _nicknames.sublist(0, _credentials.length);
    }
    await _prefs.setStringList('credentials', _credentials);
    await _prefs.setStringList('nicknames', _nicknames);
    notifyListeners();
  }
}
