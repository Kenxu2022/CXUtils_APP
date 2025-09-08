import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchToken(
  String endpoint, 
  String username,
  String password
  ) async {
  try {
    final url = '$endpoint/token';
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = {
      'username': username,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      try {
        final dynamic responseBody = jsonDecode(response.body);
        return {
          'success': true,
          'error': null,
          'token': responseBody['access_token']
        };
      } catch (parseError) {
        return {
          'success': false,
          'error': 'API返回的数据无法解析：${parseError.toString()}',
          'token': null
        };
      }
    } else {
      try {
        final dynamic responseBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': 'API请求失败: ${response.statusCode} ${responseBody['detail'] ?? '未知错误'}',
          'token': null
        };
      } catch (parseError) {
        return {
          'success': false,
          'error': 'API请求失败：HTTP ${response.statusCode}',
          'token': null
        };
      }
    }
  } catch (e) {
    String errorMessage;
    if (e.toString().contains('TimeoutException')) {
      errorMessage = 'API请求超时，请检查网络连接或API端点配置';
    } else if (e.toString().contains('FormatException') ||
        e.toString().contains('Invalid argument')) {
      errorMessage = 'API端点URL格式不正确，请检查设置';
    } else if (e.toString().contains('SocketException')) {
      errorMessage = '无法连接到API端点，请检查网络或URL配置';
    } else {
      errorMessage = '获取认证令牌时发生错误：${e.toString()}';
    }

    return {
      'success': false,
      'error': errorMessage,
      'token': null
    };
  }
}