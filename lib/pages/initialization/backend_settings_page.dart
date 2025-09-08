import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cxutils/providers/settings_provider.dart';
import 'package:cxutils/network/auth.dart';
import 'package:cxutils/utils/token_management.dart';

class BackendSettingsPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const BackendSettingsPage({super.key, required this.onSuccess});

  @override
  State<BackendSettingsPage> createState() => _BackendSettingsPageState();
}

class _BackendSettingsPageState extends State<BackendSettingsPage> {
  final _endpointController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _endpointController.text = settings.endpoint;
    _usernameController.text = settings.username;
    _passwordController.text = settings.password;
  }

  Future<void> _validateAndSave() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await fetchToken(
      _endpointController.text,
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      await settings.setEndpointValue(_endpointController.text);
      await settings.setUsername(_usernameController.text);
      await settings.setPassword(_passwordController.text);
      setToken(result['token']);
      setState(() {
        _isVerified = true;
      });
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('后端设置'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _endpointController,
                decoration: InputDecoration(
                  hintText: 'API 端点',
                  errorText: _errorMessage != null ? '' : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: '用户名',
                  errorText: _errorMessage != null ? '' : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '密码',
                  errorText: _errorMessage != null ? '' : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (!_isVerified)
                ElevatedButton(
                  onPressed: _validateAndSave,
                  child: const Text('确定'),
                )
              else
                ElevatedButton(
                  onPressed: widget.onSuccess,
                  child: const Text('下一步'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
