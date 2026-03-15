import 'package:cxutils/network/api.dart';
import 'package:cxutils/pages/home/course_selection_page.dart';
import 'package:cxutils/providers/credentials_provider.dart';
import 'package:cxutils/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _selectedUsername = [];
  String? _addCredentialError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CXUtils'),
        actions: [
          Tooltip(
            message: "设置",
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              icon: const Icon(Icons.settings_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<CredentialsProvider>(
          builder: (context, credentialsProvider, child) {
            if (!credentialsProvider.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                if (credentialsProvider.credentials.isEmpty)
                  const Center(
                    child: Text(
                      "アッカリ〜ン",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      Builder(
                        builder: (context) {
                          final credentials = credentialsProvider.credentials;
                          final allSelected = credentials.isNotEmpty &&
                              credentials.every(
                                (username) => _selectedUsername.contains(username),
                              );
                          return CheckboxListTile(
                            title: const Text('全选'),
                            value: allSelected,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedUsername
                                    ..clear()
                                    ..addAll(credentials);
                                } else {
                                  _selectedUsername.clear();
                                }
                              });
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: credentialsProvider.credentials.length,
                          itemBuilder: (context, index) {
                            final username = credentialsProvider.credentials[index];
                            final nickname =
                                credentialsProvider.nicknames.length > index
                                ? credentialsProvider.nicknames[index]
                                : '';
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: _selectedUsername.contains(username),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedUsername.add(username);
                                      } else {
                                        _selectedUsername.remove(username);
                                      }
                                    });
                                  },
                                ),
                                title: Text(username),
                                subtitle: nickname.isNotEmpty
                                    ? Text(nickname)
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () {
                                        _showEditNicknameDialog(
                                          context,
                                          username,
                                          nickname,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        final result = await deleteCredential(
                                          username,
                                        );
                                        if (result['success'] == true) {
                                          await credentialsProvider.removeUser(
                                            username,
                                          );
                                          setState(() {
                                            _selectedUsername.remove(username);
                                          });
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '成功移除用户$username',
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '移除用户失败: ${result['detail'] ?? '未知错误'}',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                if (_selectedUsername.isNotEmpty)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseSelectionPage(
                                selectedUsernames: _selectedUsername,
                              ),
                            ),
                          );
                        },
                        child: const Text('下一步'),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _addCredentialError = null;
          });
          _showAddCredentialDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCredentialDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final nicknameController = TextEditingController();
    final passwordController = TextEditingController();
    final credentialsProvider = Provider.of<CredentialsProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canSubmit =
                usernameController.text.trim().isNotEmpty &&
                passwordController.text.trim().isNotEmpty;
            return AlertDialog(
              title: const Text('输入学习通账号及密码'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: '用户名',
                      errorText: _addCredentialError,
                    ),
                  ),
                  TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(labelText: '昵称（可选）'),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: '密码',
                      errorText: _addCredentialError,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: canSubmit
                      ? () async {
                          final username = usernameController.text;
                          final password = passwordController.text;
                          final nickname = nicknameController.text.trim();
                          final result = await addCredential(
                            username,
                            password,
                            nickname,
                          );

                          if (result['success'] == true) {
                            await credentialsProvider.addUser(
                              username,
                              nickname,
                            );
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                            setState(() {
                              _addCredentialError = null;
                            });
                          } else {
                            setState(() {
                              _addCredentialError = result['detail'] ?? '未知错误';
                            });
                          }
                        }
                      : null,
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditNicknameDialog(
    BuildContext context,
    String username,
    String initialNickname,
  ) {
    final nicknameController = TextEditingController(text: initialNickname);
    final credentialsProvider = Provider.of<CredentialsProvider>(
      context,
      listen: false,
    );
    String? updateNicknameError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canSubmit = (nicknameController.text).trim() != initialNickname;
            return AlertDialog(
              title: const Text('添加或修改昵称'),
              content: TextField(
                controller: nicknameController,
                onChanged: (_) {
                  setState(() {
                    updateNicknameError = null;
                  });
                },
                decoration: InputDecoration(
                  labelText: '昵称',
                  errorText: updateNicknameError,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: canSubmit
                      ? () async {
                          final nickname = nicknameController.text.trim();
                          final result = await updateNickname(
                            username,
                            nickname,
                          );

                          if (result['success'] == true) {
                            await credentialsProvider.addUser(
                              username,
                              nickname,
                            );
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('成功更新用户$username的昵称')),
                              );
                            }
                          } else {
                            setState(() {
                              updateNicknameError = result['detail'] ?? '未知错误';
                            });
                          }
                        }
                      : null,
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
