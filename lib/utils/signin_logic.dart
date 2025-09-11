import 'package:cxutils/network/api.dart' as api;

Future<List<Map<String, dynamic>>> signInAll(
  int type,
  List<String> usernames,
  String activeID, {
  List<String>? validateCodes,
}) async {
  final List<Future<Map<String, dynamic>>> futures = [];
  for (int i = 0; i < usernames.length; i++) {
    final username = usernames[i];
    final validate = (validateCodes != null && i < validateCodes.length)
        ? validateCodes[i]
        : null;

    switch (type) {
      case 0: // normal
        futures.add(api.normalSignIn(username, activeID, validate));
        break;
      case 2: // qrcode
        futures.add(api.qrcodeSignIn(username, activeID, '123456', validate));
        break;
      case 4: // location
        futures.add(api.locationSignIn(username, activeID, validate));
        break;
      case 3:
      case 5: // signcode
        futures.add(api.signcodeSignIn(username, activeID, '123456', validate));
        break;
      default:
        futures.add(Future.value({
          'success': false,
          'data': '未知类型: $type',
        }));
    }
  }

  final rawResults = await Future.wait(futures);
  final withUser = <Map<String, dynamic>>[];
  for (int i = 0; i < rawResults.length; i++) {
    withUser.add({
      'username': usernames[i],
      ...rawResults[i],
    });
  }
  return withUser;
}
