import '../network/auth.dart';
import 'package:cxutils/providers/settings_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

String? _token;
String? _lastTokenError;

String? get token => _token;
String? get lastTokenError => _lastTokenError;

void setToken(String token) {
  _token = token;
}

void clearToken() {
  _token = null;
  _lastTokenError = null;
}

Future<String?> _refreshToken() async {
  final settingsProvider = SettingsProvider.instance;
  final username = settingsProvider.username;
  final password = settingsProvider.password;
  final endpoint = settingsProvider.endpoint;
  
  if (username.isEmpty || password.isEmpty || endpoint.isEmpty) {
    _lastTokenError = '后端账号或端点未配置完整，请先在设置中完成配置';
    _token = null;
    return null;
  }
  
  try {
    final result = await fetchToken(endpoint, username, password);
    if (result['success'] == true) {
      _token = result['token'];
      _lastTokenError = null;
      return _token;
    }
    else {
      _lastTokenError = '获取Token失败：${result['error'] ?? '未知错误'}';
      _token = null;
      return null;
    }
  } catch (e) {
    _lastTokenError = '获取Token失败：$e';
    _token = null;
    return null;
  }
}

Future<String?> getToken () async {
  if (_token == null) {
    return await _refreshToken();
  }

  bool hasExpired = JwtDecoder.isExpired(_token!);
  if (hasExpired) {
    return await _refreshToken();
  }

  return _token;
}
