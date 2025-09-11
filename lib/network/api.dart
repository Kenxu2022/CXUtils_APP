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

Future<Map<String, dynamic>> getCourse(
  /* return format:
  {
    'success': bool,
    'data': List<Map<String, dynamic>> | String, // if success is true, data is List<Map<String, dynamic>>, else data is String (error message)
      format: [
        {
          'name': 
          'teacher': 
          'courseID':
          'classID': 
        },
        ...
      ]
  }
  */
  String username,
) async {
  final url = '${settings.endpoint}/getCourse';
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
      'data': '请求超时，请检查网络',
    };
  }
}

Future<Map<String, dynamic>> getActivity(
  /* return format:
  {
    'success': bool,
    'data': List<Map<String, dynamic>> | String, // if success is true, data is List<Map<String, dynamic>>, else data is String (error message)
      format: [
        {
          'name': 
          'startTime': 
          'endTime':
          'active': --> Boolean, whether the activity is currently active
          'activeID': 
          'activeType':
        },
        ...
      ]
  }
  */
  String username,
  String courseID,
  String classID,
) async {
  final url = '${settings.endpoint}/getActivity';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await getToken()}',
  };
  final body = jsonEncode({
    'username': username,
    'courseID': courseID,
    'classID': classID,
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
      'data': '请求超时，请检查网络',
    };
  }
}

Future<Map<String, dynamic>> getSignInDetail(
  /* return format:
  {
    'success': bool,
    'detail': Map<String, dynamic> | String, // if success is true, data is List<Map<String, dynamic>>, else data is String (error message)
      format: {
          'type': int, --> 0-normal, 2-QRCode, 3-gesture, 4-location, 5-signcode
          'needValidation': bool,
        }
  }
  */
  String username,
  String activeID,
) async {
  final url = '${settings.endpoint}/getSignInDetail';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await getToken()}',
  };
  final body = jsonEncode({
    'username': username,
    'activeID': activeID,
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

Future<Map<String, dynamic>> getValidateCode(
  /* return format:
  {
    'success': bool,
    'code': String,
  }
  */
  String username,
  String courseID,
  String classID,
  String activeID,
) async {
  final url = '${settings.endpoint}/getValidateCode';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await getToken()}',
  };
  final body = jsonEncode({
    'username': username,
    'courseID': courseID,
    'classID': classID,
    'activeID': activeID,
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
      'code': '请求超时，请检查网络',
    };
  }
}