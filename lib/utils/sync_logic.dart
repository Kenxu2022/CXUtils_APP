import 'package:flutter/material.dart';
import 'package:cxutils/network/api.dart';
import 'package:cxutils/providers/credentials_provider.dart';

typedef ShowSyncUsersErrorDialog =
    Future<void> Function(BuildContext context, String detail);
typedef ShowSyncUsersConfirmDialog =
    Future<bool?> Function(
      BuildContext context, {
      required List<String> usersToAdd,
      required List<String> usersToRemove,
      required List<String> usersToUpdateNickname,
      required List<String> localUsers,
      required List<String> localNicknames,
      required List<String> serverUsers,
      required List<String> serverNicknames,
    });

Future<void> syncUsersFromServer({
  required BuildContext context,
  required CredentialsProvider credentialsProvider,
  required ShowSyncUsersErrorDialog showErrorDialog,
  required ShowSyncUsersConfirmDialog showConfirmDialog,
  bool showConfirmWhenNoChanges = true,
}) async {
  final result = await syncUsers();

  if (!context.mounted) {
    return;
  }

  if (result['detail'] is String) {
    await showErrorDialog(context, result['detail'] as String);
    return;
  }

  final List<String> localUsers = credentialsProvider.credentials;
  final List<String> localNicknames = credentialsProvider.nicknames;
  final List<String> serverUsers = [];
  final List<String> serverNicknames = [];
  final dynamic data = result['data'];
  if (data is List) {
    for (final dynamic user in data) {
      serverUsers.add(user[0]);
      serverNicknames.add(user[1]);
    }
  }

  final List<String> usersToAdd = serverUsers
      .where((String user) => !localUsers.contains(user))
      .toList();
  final List<String> usersToRemove = localUsers
      .where((String user) => !serverUsers.contains(user))
      .toList();
  final List<String> usersToUpdateNickname = localUsers
      .where(
        (String user) =>
            serverUsers.contains(user) &&
            localNicknames[localUsers.indexOf(user)] !=
                serverNicknames[serverUsers.indexOf(user)],
      )
      .toList();

  if (!showConfirmWhenNoChanges &&
      usersToAdd.isEmpty &&
      usersToRemove.isEmpty &&
      usersToUpdateNickname.isEmpty) {
    return;
  }

  final bool shouldApply =
      await showConfirmDialog(
        context,
        usersToAdd: usersToAdd,
        usersToRemove: usersToRemove,
        usersToUpdateNickname: usersToUpdateNickname,
        localUsers: localUsers,
        localNicknames: localNicknames,
        serverUsers: serverUsers,
        serverNicknames: serverNicknames,
      ) ??
      false;

  if (!shouldApply) {
    return;
  }

  for (final String username in usersToAdd) {
    final nickname = serverNicknames[serverUsers.indexOf(username)];
    await credentialsProvider.addUser(username, nickname);
  }
  for (final String username in usersToRemove) {
    await credentialsProvider.removeUser(username);
  }
  for (final String username in usersToUpdateNickname) {
    final nickname = serverNicknames[serverUsers.indexOf(username)];
    await credentialsProvider.addUser(username, nickname);
  }
}
