import '../network/auth.dart';
import 'package:cxutils/providers/settings_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

String? _token;

String? get token => _token;

void setToken(String token) {
  _token = token;
}

void clearToken() {
  _token = null;
}

Future<String?> _refreshToken() async {
  final settingsProvider = SettingsProvider.instance;
  final username = settingsProvider.username;
  final password = settingsProvider.password;
  final endpoint = settingsProvider.endpoint;
  
  if (username.isEmpty || password.isEmpty || endpoint.isEmpty) {
    return null;
  }
  
  try {
    final result = await fetchToken(endpoint, username, password);
    if (result['success'] == true) {
      _token = result['token'];
      return _token;
    }
    else {
      return 'Error getting token: ${result['error']}';
    }
  } catch (e) {
    return 'Error getting token: $e';
  }
}

Future<String?> getToken () async {
  if (_token == null) {
    _token = await _refreshToken();
    return _token;
  }
  else {
    bool hasExpired = JwtDecoder.isExpired(_token!);
    if (hasExpired) {
      _token = await _refreshToken();
    }
    return _token;
  }
}
