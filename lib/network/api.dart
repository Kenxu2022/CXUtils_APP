import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cxutils/utils/token_management.dart';
import 'package:cxutils/providers/settings_provider.dart';

final settings = SettingsProvider.instance;

Future<Map<String, dynamic>> addCredential(
  /* return format:
  {
    'success': bool,
    'detail': String?,
  }
  */
  String username,
  String password,
) async {
  final url = '${settings.endpoint}/addCredential';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await getToken()}',
  };
  final body = jsonEncode({
    'username': username,
    'password': password,
  });

  try {
    final response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 5));
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    return responseBody;
  } on TimeoutException {
    return {
      'success': false,
      'detail': '请求超时，请检查网络',
    };
  }
}

Future<Map<String, dynamic>> deleteCredential(
  /* return format:
  {
    'success': bool,
    'detail': String?,
  }
  */
  String username,
) async {
  final url = '${settings.endpoint}/deleteCredential';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await getToken()}',
  };
  final body = jsonEncode({
    'username': username,
  });

  try {
    final response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 5));
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    return responseBody;
  } on TimeoutException {
    return {
      'success': false,
      'detail': '请求超时，请检查网络',
    };
  }
}