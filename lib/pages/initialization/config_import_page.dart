import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:cxutils/network/auth.dart';
import 'package:cxutils/providers/credentials_provider.dart';
import 'package:cxutils/providers/settings_provider.dart';
import 'package:cxutils/pages/home/home_page.dart';
import 'package:cxutils/utils/token_management.dart';

class ConfigImportPage extends StatefulWidget {
	const ConfigImportPage({super.key});

	@override
	State<ConfigImportPage> createState() => _ConfigImportPageState();
}

class _ConfigImportPageState extends State<ConfigImportPage> {
	final MobileScannerController _controller = MobileScannerController(
		autoZoom: false,
	);
	final String _scriptUrl = 'barcode.js';
	bool _handled = false;
	bool _isImporting = false;

	@override
	void initState() {
		super.initState();
		if (kIsWeb) {
			MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl(_scriptUrl);
		}
	}

	Future<void> _showErrorDialog(String message) async {
		await showDialog<void>(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: const Text('导入失败'),
					content: Text(message),
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

	bool _isValidConfig(Map<String, dynamic> data) {
		const requiredKeys = <String>{
			'endpoint',
			'username',
			'password',
			'latitude',
			'longitude',
			'locationText',
			'credentials',
			'nicknames',
		};

		if (!requiredKeys.every(data.containsKey)) {
			return false;
		}

		if (data['endpoint'] is! String ||
				data['username'] is! String ||
				data['password'] is! String ||
				data['latitude'] is! String ||
				data['longitude'] is! String ||
				data['locationText'] is! String ||
				data['credentials'] is! List ||
				data['nicknames'] is! List) {
			return false;
		}

		final credentials = data['credentials'] as List;
		final nicknames = data['nicknames'] as List;

		if (credentials.any((item) => item is! String) ||
				nicknames.any((item) => item is! String) ||
				credentials.length != nicknames.length) {
			return false;
		}

		return true;
	}

	Future<void> _handleRawCode(String raw) async {
		if (_handled || _isImporting) return;

		final settingsProvider = Provider.of<SettingsProvider>(
			context,
			listen: false,
		);
		final credentialsProvider = Provider.of<CredentialsProvider>(
			context,
			listen: false,
		);

		_handled = true;
		setState(() {
			_isImporting = true;
		});

		Map<String, dynamic> config;
		try {
			final decoded = jsonDecode(raw);
			if (decoded is! Map<String, dynamic> || !_isValidConfig(decoded)) {
				throw const FormatException('invalid config format');
			}
			config = decoded;
		} catch (_) {
			if (mounted) {
				await _showErrorDialog('二维码格式错误');
				setState(() {
					_isImporting = false;
				});
				_handled = false;
			}
			return;
		}

		final endpoint = config['endpoint'] as String;
		final username = config['username'] as String;
		final password = config['password'] as String;

		final result = await fetchToken(endpoint, username, password);
		if (result['success'] != true) {
			if (mounted) {
				await _showErrorDialog('后端用户名或密码错误');
				setState(() {
					_isImporting = false;
				});
				_handled = false;
			}
			return;
		}

		await settingsProvider.setEndpointValue(endpoint);
		await settingsProvider.setUsername(username);
		await settingsProvider.setPassword(password);
		await settingsProvider.setLatitude(config['latitude'] as String);
		await settingsProvider.setLongitude(config['longitude'] as String);
		await settingsProvider.setLocationText(config['locationText'] as String);
		await settingsProvider.setInitializationFinished(true);

		await credentialsProvider.setUsers(
			List<String>.from(config['credentials'] as List),
			List<String>.from(config['nicknames'] as List),
		);

		setToken(result['token'] as String);

		if (!mounted) return;
		Navigator.of(context).pushAndRemoveUntil(
			MaterialPageRoute(builder: (_) => const HomePage()),
			(route) => false,
		);
	}

	void _onDetect(BarcodeCapture capture) {
		if (_handled || _isImporting) return;
		for (final barcode in capture.barcodes) {
			final raw = barcode.rawValue;
			if (raw == null || raw.isEmpty) continue;
			_handleRawCode(raw);
			return;
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('扫码导入配置')),
			body: SafeArea(
				child: Center(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							const Text(
								'请扫描配置二维码',
								style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
							),
							const SizedBox(height: 16),
							ClipRRect(
								borderRadius: BorderRadius.circular(12),
								child: SizedBox(
									width: 350,
									height: 350,
									child: MobileScanner(
										controller: _controller,
										onDetect: _onDetect,
									),
								),
							),
							const SizedBox(height: 16),
							if (_isImporting) const CircularProgressIndicator(),
						],
					),
				),
			),
		);
	}
}

