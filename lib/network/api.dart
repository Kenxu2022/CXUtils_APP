import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cxutils/utils/token_management.dart';
import 'package:cxutils/providers/settings_provider.dart';

final settings = SettingsProvider.instance;

Map<String, dynamic> _tokenFailedResponse() {
  final String detail = lastTokenError ?? '获取Token失败，请稍后重试';
  return {
    'success': false,
    'detail': detail,
    'data': detail,
  };
}

Future<Map<String, dynamic>> addCredential(
  /* return format:
  {
    'success': bool,
    'detail': String?,
  }
  */
  String username,
  String password,
  String nickname,
) async {
  final url = '${settings.endpoint}/addCredential';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'password': password,
    'nickname': nickname,
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
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
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

Future<Map<String, dynamic>> syncUsers(
  /* return format:
  if disabled, return 403 with body:
  {
    'detail': String,
  }
  else return list of users:
  {
    'success': bool,
    'data': List<List<String>> | String, // if success is true, data is List<List<String>> (username, nickname), else data is String (error message)
  }
  */
) async {
  final url = '${settings.endpoint}/syncUsers';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  try {
    final response = await http
        .post(
          Uri.parse(url),
          headers: headers,
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

Future<Map<String, dynamic>> updateNickname(
  /* return format:
  {
    'success': bool,
    'detail': String?,
  }
  */
  String username,
  String nickname,
) async {
  final url = '${settings.endpoint}/updateNickname';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'nickname': nickname,
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
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
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
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'courseID': courseID,
    'classID': classID,
    'activityType': [2, 42, 5, 4] // currently supported activity type 
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

Future<Map<String, dynamic>> uploadImage(
  /* return format:
  {
    'success': bool,
    'detail': null | String, // if success is true, detail is null, else data is String (error message)
    'objectId': String | null, // if success is true, objectId is String, else data is null
  }
  */
  String username,
  String imageFilePath,
) async {
  final url = '${settings.endpoint}/uploadImage';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final request = http.MultipartRequest('POST', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer $authToken';
  request.fields['username'] = username;
  request.files.add(await http.MultipartFile.fromPath('image', imageFilePath));

  try {
    final response = await request.send().timeout(const Duration(seconds: 5));
    final responseBodyString = await response.stream.bytesToString();
    final Map<String, dynamic> responseBody = jsonDecode(responseBodyString);
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
          'needLocation': bool,
          'needPhoto': bool
        }
  }
  */
  String username,
  String activeID,
) async {
  final url = '${settings.endpoint}/getSignInDetail';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
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
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
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
        .timeout(const Duration(seconds: 15));
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    return responseBody;
  } on TimeoutException {
    return {
      'success': false,
      'code': '请求超时，请检查网络',
    };
  }
}

Future<Map<String, dynamic>> normalSignIn(
  /* return format:
  {
    'success': bool,
    'detail': null | String, // if success is true, data is null, else data is String (error message)
  }
  */
  String username,
  String activeID,
  [String? validate, String? objectId]
) async {
  final url = '${settings.endpoint}/normalSignIn';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'activeID': activeID,
    'validate': validate,
    'objectId': objectId,
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

Future<Map<String, dynamic>> locationSignIn(
  /* return format:
  {
    'success': bool,
    'detail': null | String, // if success is true, data is null, else data is String (error message)
  }
  */
  String username,
  String activeID,
  [String? validate]
) async {
  final url = '${settings.endpoint}/locationSignIn';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'activeID': activeID,
    'locationText': settings.locationText,
    'locationLatitude': settings.latitude,
    'locationLongitude': settings.longitude,
    'validate': validate,
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

Future<Map<String, dynamic>> qrcodeSignIn(
  /* return format:
  {
    'success': bool,
    'detail': null | String, // if success is true, data is null, else data is String (error message)
  }
  */
  String username,
  String activeID,
  String enc,
  bool needLocation,
  [String? validate]
) async {
  final url = '${settings.endpoint}/qrcodeSignIn';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = needLocation ? jsonEncode({
    'username': username,
    'activeID': activeID,
    'enc': enc,
    'locationText': settings.locationText,
    'locationLatitude': settings.latitude,
    'locationLongitude': settings.longitude,
    'validate': validate,
  }) :
  jsonEncode({
    'username': username,
    'activeID': activeID,
    'enc': enc,
    'validate': validate,
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

Future<Map<String, dynamic>> signCodeSignIn(
  /* return format:
  {
    'success': bool,
    'detail': null | String, // if success is true, data is null, else data is String (error message)
  }
  */
  String username,
  String activeID,
  String signCode,
  [String? validate]
) async {
  final url = '${settings.endpoint}/signcodeSignIn';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'activeID': activeID,
    'signCode': signCode,
    'validate': validate,
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

Future<Map<String, dynamic>> getQuizDetail(
  /* return format:
  {
    'success': bool,
    'data': List<Map<String, dynamic>> | String, // if success is true, data is List<Map<String, dynamic>>, else data is String (error message)
      format: [ // list of problems
            {
              'title': String, // title of the problem
              'type': int, --> 0-single choice, 1-multiple choice, 2-fill in the blank, 4-essay, 16-judgment
              'options': null | Map<dynamic, dynamic>, // ignore when type == 4, key = option name, value = option content
              'resourceUrl': null | List<String>, // image urls
            },
            ...
          ]
    'originalData': List<Map<String, dynamic>>
  }
  */
  String username,
  String activeID, 
) async {
  final url = '${settings.endpoint}/getQuizProblem';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
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
      'data': '请求超时，请检查网络',
    };
  }
}

Future<Map<String, dynamic>> submitQuizProblem(
  /* return format:
  {
    'success': bool,
    'detail': null | String, // if success is true, data is null, else data is String (error message)
  }
  */
  String username,
  String courseID,
  String classID,
  String activeID,
  List<Map<String, dynamic>> data,
) async {
  final url = '${settings.endpoint}/submitQuizProblem';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'courseID': courseID,
    'classID': classID,
    'activeID': activeID,
    'data': data,
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

Future<Map<String, dynamic>> getDiscussion(
  /* return format:
  {
    'success': bool,
    'data': Map<String, dynamic> | String, // if success is true, data is List<Map<String, dynamic>>, else data is String (error message)
      format: {
              'content': String,
              'publicURL': String,
              'uuid': String,
              'bbsid': String
            }
  */
  String username,
  String activeID, 
) async {
  final url = '${settings.endpoint}/getDiscussion';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
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
      'data': '请求超时，请检查网络',
    };
  }
}

Future<Map<String, dynamic>> getReply(
  /* return format:
  {
    'success': bool,
    'data': List<Map<String, dynamic>> | String, // if success is true, data is List<Map<String, dynamic>>, else data is String (error message)
      format: [ // list of replies
            {
              'floor': String, // name of this floor
              'name': String, // replyer's nickname
              'content': String,
            },
            ...
          ]
  }
  */
  String username,
  String uuid,
  String bbsid,
) async {
  final url = '${settings.endpoint}/getReply';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'uuid': uuid,
    'bbsid': bbsid,
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

Future<Map<String, dynamic>> submitReply(
  /* return format:
  {
    'success': bool,
    'detail': null | String, // if success is true, data is null, else data is String (error message)
  }
  */
  String username,
  String courseID,
  String classID,
  String uuid,
  String bbsid,
  String content,
) async {
  final url = '${settings.endpoint}/submitReply';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  final body = jsonEncode({
    'username': username,
    'courseID': courseID,
    'classID': classID,
    'uuid': uuid,
    'bbsid': bbsid,
    'content': content,
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

Future<Map<String, dynamic>> getBuzzIn(
  /* return format:
  {
    'success': bool,
    'data': Map<String, dynamic> | String, // if success is true, data is List<Map<String, dynamic>>, else data is String (error message)
      format: {
              'attendList': [ // in order
                {
                  'name': String,
                  'answerTime': String,
                },
                ...
              ]
              'startTime': String,
              'endTime': String,
              'hasEnded': bool,
              'allowAnswerStuNum': int, // number of students allowed to buzz in, 0 means no limit
            }
  */
  String username,
  String courseID,
  String classID,
  String activeID, 
) async {
  final url = '${settings.endpoint}/getBuzzIn';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
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
      'data': '请求超时，请检查网络',
    };
  }
}

Future<Map<String, dynamic>> submitBuzzIn(
  /* return format:
  {
    'success': bool,
    'detail': null | String, // if success is true, data is null, else data is String (error message)
  }
  */
  String username,
  String courseID,
  String classID,
  String activeID,
) async {
  final url = '${settings.endpoint}/submitBuzzIn';
  final authToken = await getToken();
  if (authToken == null) {
    return _tokenFailedResponse();
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
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
      'detail': '请求超时，请检查网络',
    };
  }
}
