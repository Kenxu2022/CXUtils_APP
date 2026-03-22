import 'package:cxutils/network/api.dart' as api;
import 'package:cxutils/pages/home/camera_page.dart';
import 'package:cxutils/providers/credentials_provider.dart';
import 'package:flutter/material.dart';

class UploadImagePage extends StatefulWidget {
	final List<String> selectedUsernames;

	const UploadImagePage({
		super.key,
		required this.selectedUsernames,
	});

	@override
	State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
	final CredentialsProvider _credentialsProvider = CredentialsProvider.instance;
	final Map<String, bool> _skipUpload = {};
	final Map<String, bool> _isUploading = {};
	final Map<String, String?> _imagePaths = {};
	final Map<String, String?> _uploadedObjectIds = {};

	@override
	void initState() {
		super.initState();
		for (final username in widget.selectedUsernames) {
			_skipUpload[username] = false;
			_isUploading[username] = false;
			_imagePaths[username] = null;
			_uploadedObjectIds[username] = null;
		}
	}

	String? _displayName(String username) {
		final index = _credentialsProvider.credentials.indexOf(username);
		if (index < 0 || index >= _credentialsProvider.nicknames.length) {
			return null;
		}
		final nickname = _credentialsProvider.nicknames[index].trim();
		return nickname.isEmpty ? null : nickname;
	}

	bool get _canComplete {
		for (final username in widget.selectedUsernames) {
			final skipped = _skipUpload[username] == true;
			final uploaded = (_uploadedObjectIds[username] ?? '').isNotEmpty;
			if (!skipped && !uploaded) {
				return false;
			}
		}
		return true;
	}

	Future<void> _uploadForUser(String username) async {
		if (_skipUpload[username] == true || _isUploading[username] == true) {
			return;
		}

		final imagePath = await Navigator.of(context).push<String>(
			MaterialPageRoute(builder: (_) => const CameraPage()),
		);
		if (!mounted || imagePath == null || imagePath.isEmpty) {
			return;
		}

		setState(() {
			_isUploading[username] = true;
			_imagePaths[username] = imagePath;
		});

		try {
			final response = await api.uploadImage(username, imagePath);
			if (!mounted) {
				return;
			}

			if (response['success'] == true) {
				setState(() {
					_uploadedObjectIds[username] = (response['objectId'] ?? '').toString();
				});
			} else {
				final detail = (response['detail'] ?? '图片上传失败').toString();
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('$username: $detail')),
				);
			}
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('$username: 上传异常: $e')),
				);
			}
		} finally {
			if (mounted) {
				setState(() {
					_isUploading[username] = false;
				});
			}
		}
	}

	Future<void> _onSkipUploadChanged(String username, bool value) async {
		if (!value) {
			setState(() {
				_skipUpload[username] = false;
			});
			return;
		}

		final hasUploaded = (_uploadedObjectIds[username] ?? '').isNotEmpty;
		if (!hasUploaded) {
			setState(() {
				_skipUpload[username] = true;
			});
			return;
		}

		final shouldClear = await showDialog<bool>(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('清除已上传图片'),
				content: const Text('该用户已上传图片，开启“跳过上传”将清除已上传图片信息，是否继续？'),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(context).pop(false),
						child: const Text('取消'),
					),
					TextButton(
						onPressed: () => Navigator.of(context).pop(true),
						child: const Text('确认'),
					),
				],
			),
		);

		if (!mounted || shouldClear != true) {
			return;
		}

		setState(() {
			_skipUpload[username] = true;
			_uploadedObjectIds[username] = null;
			_imagePaths[username] = null;
		});
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			appBar: AppBar(title: const Text('上传图片')),
			body: SafeArea(
				child: Column(
					children: [
						Expanded(
							child: ListView.builder(
								itemCount: widget.selectedUsernames.length,
								itemBuilder: (context, index) {
									final username = widget.selectedUsernames[index];
									final isSkipping = _skipUpload[username] == true;
									final isUploading = _isUploading[username] == true;
									final hasUploaded =
											(_uploadedObjectIds[username] ?? '').isNotEmpty;
									final nickname = _displayName(username);
									final displayTitle = nickname == null
											? username
											: '$username ($nickname)';
									final buttonText = isUploading
											? '上传中'
											: (hasUploaded ? '重新上传' : '上传图片');
									final buttonBackgroundColor = hasUploaded
											? Colors.lightGreen.shade200
											: colorScheme.secondaryContainer;
									final buttonForegroundColor = hasUploaded
											? Colors.green.shade900
											: colorScheme.onSecondaryContainer;

									return Card(
										margin: const EdgeInsets.symmetric(
											horizontal: 12,
											vertical: 6,
										),
										child: ListTile(
											title: Text(displayTitle),
											subtitle: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												mainAxisSize: MainAxisSize.min,
												children: [
													Row(
														mainAxisSize: MainAxisSize.min,
														children: [
															const Text('跳过上传', style: TextStyle(fontSize: 14)),
															const SizedBox(width: 8),
															Switch(
																value: isSkipping,
																onChanged: isUploading
																		? null
																		: (value) => _onSkipUploadChanged(username, value),
															),
														],
													),
												],
											),
											trailing: FilledButton(
												style: FilledButton.styleFrom(
													backgroundColor: buttonBackgroundColor,
													foregroundColor: buttonForegroundColor,
												),
												onPressed: (isSkipping || isUploading)
														? null
														: () => _uploadForUser(username),
												child: Text(buttonText),
											),
										),
									);
								},
							),
						),
						Padding(
							padding: const EdgeInsets.symmetric(vertical: 16),
							child: Center(
								child: ElevatedButton(
									onPressed: _canComplete
											? () {
													final Map<String, String> uploaded = {};
													for (final username in widget.selectedUsernames) {
														final objectId = _uploadedObjectIds[username];
														if (objectId != null && objectId.isNotEmpty) {
															uploaded[username] = objectId;
														}
													}
													Navigator.of(context).pop(uploaded);
												}
											: null,
									child: const Text('完成签到'),
								),
							),
						),
					],
				),
			),
		);
	}
}
