import 'package:cxutils/network/api.dart';
import 'package:cxutils/pages/home/course_selection_page.dart';
import 'package:cxutils/providers/credentials_provider.dart';
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
                  ListView.builder(
                    itemCount: credentialsProvider.credentials.length,
                    itemBuilder: (context, index) {
                      final username = credentialsProvider.credentials[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final result = await deleteCredential(username);
                              if (result['success'] == true) {
                                await credentialsProvider.removeUser(username);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('成功移除用户$username'),
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '移除用户失败: ${result['detail'] ?? '未知错误'}'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
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
    final passwordController = TextEditingController();
    final credentialsProvider =
        Provider.of<CredentialsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('输入学习通账号及密码'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: '用户名',
                      errorText: _addCredentialError,
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
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
                  onPressed: () async {
                    final username = usernameController.text;
                    final password = passwordController.text;
                    final result = await addCredential(username, password);

                    if (result['success'] == true) {
                      await credentialsProvider.addUser(username);
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
                  },
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

