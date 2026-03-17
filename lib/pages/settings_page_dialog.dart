import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cxutils/providers/credentials_provider.dart';
import 'package:cxutils/providers/settings_provider.dart';

Future<void> showLocationDialog(
  BuildContext context,
  SettingsProvider settingsProvider,
) async {
  final latitudeController = TextEditingController(
    text: settingsProvider.latitude,
  );
  final longitudeController = TextEditingController(
    text: settingsProvider.longitude,
  );
  final locationTextController = TextEditingController(
    text: settingsProvider.locationText,
  );

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('修改位置信息'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: latitudeController,
                decoration: const InputDecoration(
                  labelText: '纬度',
                  hintText: '例如: 39.90923',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: longitudeController,
                decoration: const InputDecoration(
                  labelText: '经度',
                  hintText: '例如: 116.397428',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: locationTextController,
                decoration: const InputDecoration(
                  labelText: '位置名称',
                  hintText: '例如: 天安门广场',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () async {
              await settingsProvider.setLatitude(latitudeController.text);
              await settingsProvider.setLongitude(longitudeController.text);
              await settingsProvider.setLocationText(
                locationTextController.text,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> showOverrideDialog(
  BuildContext context,
  SettingsProvider settingsProvider,
) async {
  final courseIDController = TextEditingController(
    text: settingsProvider.overrideCourseID,
  );
  final classIDController = TextEditingController(
    text: settingsProvider.overrideClassID,
  );
  final formKey = GlobalKey<FormState>();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: courseIDController,
                  decoration: const InputDecoration(labelText: 'CourseID'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextFormField(
                  controller: classIDController,
                  decoration: const InputDecoration(labelText: 'ClassID'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await settingsProvider.setOverrideCourseID(
                  courseIDController.text,
                );
                await settingsProvider.setOverrideClassID(
                  classIDController.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> showSyncUsersErrorDialog(
  BuildContext context,
  String detail,
) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('同步失败'),
        content: Text(detail),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}

Future<bool?> showSyncUsersConfirmDialog(
  BuildContext context, {
  required List<String> usersToAdd,
  required List<String> usersToRemove,
  required List<String> usersToUpdateNickname,
  required List<String> localUsers,
  required List<String> localNicknames,
  required List<String> serverUsers,
  required List<String> serverNicknames,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('同步账号信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('是否添加以下账号：'),
            const SizedBox(height: 8),
            if (usersToAdd.isEmpty)
              const Text('暂无可添加账号')
            else
              ...usersToAdd.map((String username) {
                final nickname = serverNicknames[serverUsers.indexOf(username)];
                return nickname.isEmpty
                    ? Text('• $username')
                    : Text('• $username ($nickname)');
              }),
            const SizedBox(height: 12),
            const Text('是否删除以下本地账号：'),
            const SizedBox(height: 8),
            if (usersToRemove.isEmpty)
              const Text('暂无可删除账号')
            else
              ...usersToRemove.map((String username) {
                final nickname = localNicknames[localUsers.indexOf(username)];
                return nickname.isEmpty
                    ? Text('• $username')
                    : Text('• $username ($nickname)');
              }),
            const SizedBox(height: 12),
            const Text('是否同步以下账号昵称：'),
            const SizedBox(height: 8),
            if (usersToUpdateNickname.isEmpty)
              const Text('暂无可同步昵称')
            else
              ...usersToUpdateNickname.map((String username) {
                final localNickname =
                    localNicknames[localUsers.indexOf(username)];
                final serverNickname =
                    serverNicknames[serverUsers.indexOf(username)];
                return Text('• $username: $localNickname -> $serverNickname');
              }),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed:
                usersToAdd.isEmpty &&
                    usersToRemove.isEmpty &&
                    usersToUpdateNickname.isEmpty
                ? null
                : () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}

Future<void> showQRCodeDialog(
  BuildContext context,
  SettingsProvider settingsProvider,
  CredentialsProvider credentialsProvider,
) async {
  final String qrData = jsonEncode(<String, dynamic>{
    'endpoint': settingsProvider.endpoint,
    'username': settingsProvider.username,
    'password': settingsProvider.password,
    'latitude': settingsProvider.latitude,
    'longitude': settingsProvider.longitude,
    'locationText': settingsProvider.locationText,
    'credentials': credentialsProvider.credentials,
    'nicknames': credentialsProvider.nicknames,
  });

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('配置二维码'),
        content: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: SizedBox(
            width: 250,
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}
