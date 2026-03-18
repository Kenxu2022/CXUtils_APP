import 'package:flutter/material.dart';
import 'package:cxutils/network/api.dart' as api;
import 'package:cxutils/providers/credentials_provider.dart';
import 'package:cxutils/pages/home/discussion_submission_page.dart';

class DiscussionPage extends StatefulWidget {
  final List<String> selectedUsernames;
  final List<String> selectedCourseDetails;
  final String selectedActiveID;

  const DiscussionPage({
    super.key,
    required this.selectedUsernames,
    required this.selectedCourseDetails,
    required this.selectedActiveID,
  });

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  bool _isLoading = true;
  String? _error;
  String _discussionContent = '';
  String _discussionUuid = '';
  String _discussionBbsid = '';
  final Map<String, TextEditingController> _replyControllers = {};
  final Set<String> _replyLoadingUsers = {};

  @override
  void initState() {
    super.initState();
    for (final username in widget.selectedUsernames) {
      final controller = TextEditingController();
      controller.addListener(_onAnyReplyChanged);
      _replyControllers[username] = controller;
    }
    _fetchDiscussion();
  }

  @override
  void dispose() {
    for (final controller in _replyControllers.values) {
      controller.removeListener(_onAnyReplyChanged);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDiscussion() async {
    try {
      final response = await api.getDiscussion(
        widget.selectedUsernames.first,
        widget.selectedActiveID,
      );

      if (response['success'] == true) {
        final data = Map<String, dynamic>.from(response['data']);
        setState(() {
          _discussionContent = (data['content'] ?? '').toString();
          _discussionUuid = (data['uuid'] ?? '').toString();
          _discussionBbsid = (data['bbsid'] ?? '').toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = (response['data'] ?? '获取讨论信息失败').toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '加载讨论信息失败: $e';
        _isLoading = false;
      });
    }
  }

  void _onAnyReplyChanged() {
    setState(() {});
  }

  bool _canApplySameContent(String username) {
    if (widget.selectedUsernames.length <= 1) {
      return false;
    }
    final controller = _replyControllers[username];
    if (controller == null) {
      return false;
    }
    return controller.text.trim().isNotEmpty;
  }

  bool get _canSubmit {
    if (_replyControllers.isEmpty) {
      return false;
    }
    for (final controller in _replyControllers.values) {
      if (controller.text.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  String _displayUsername(String username) {
    final provider = CredentialsProvider.instance;
    final index = provider.credentials.indexOf(username);
    if (index != -1 && index < provider.nicknames.length) {
      final nickname = provider.nicknames[index].trim();
      if (nickname.isNotEmpty) {
        return '$username（$nickname）';
      }
    }
    return username;
  }

  void _applyToAllUsers(String username) {
    final sourceController = _replyControllers[username];
    if (sourceController == null) {
      return;
    }
    final sourceText = sourceController.text;
    if (sourceText.trim().isEmpty) {
      return;
    }

    setState(() {
      for (final controller in _replyControllers.values) {
        controller.text = sourceText;
      }
    });
  }

  void _submitReplies() {
    if (!_canSubmit) {
      return;
    }

    final replyContents = <String, String>{};
    for (final username in widget.selectedUsernames) {
      final controller = _replyControllers[username];
      replyContents[username] = controller?.text.trim() ?? '';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiscussionSubmissionPage(
          usernames: List<String>.from(widget.selectedUsernames),
          courseID: widget.selectedCourseDetails[0],
          classID: widget.selectedCourseDetails[1],
          uuid: _discussionUuid,
          bbsid: _discussionBbsid,
          replyContents: replyContents,
        ),
      ),
    );
  }

  bool _isReplyLoading(String username) {
    return _replyLoadingUsers.contains(username);
  }

  Future<void> _showReplyBottomSheet(String username) async {
    if (_isReplyLoading(username)) {
      return;
    }

    if (_discussionUuid.isEmpty || _discussionBbsid.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('讨论信息不完整，无法获取他人回复')));
      return;
    }
    setState(() {
      _replyLoadingUsers.add(username);
    });

    Map<String, dynamic> response;
    try {
      response = await api.getReply(
        username,
        _discussionUuid,
        _discussionBbsid,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取回复失败: $e')));
      }
      return;
    } finally {
      if (mounted) {
        setState(() {
          _replyLoadingUsers.remove(username);
        });
      }
    }

    if (!mounted) {
      return;
    }

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((response['data'] ?? '获取回复失败').toString())),
      );
      return;
    }

    final replies = List<Map<String, dynamic>>.from(response['data']);
    String? selectedReplyKey;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (replies.isEmpty) {
              return const SafeArea(
                child: SizedBox(
                  height: 220,
                  child: Center(child: Text('暂无可用回复')),
                ),
              );
            }

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '使用他人回复',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          final reply = replies[index];
                          final floor = (reply['floor'] ?? '').toString();
                          final name = (reply['name'] ?? '').toString();
                          final content = (reply['content'] ?? '').toString();
                          final replyKey = '$index:$floor:$name';
                          final isSelected = selectedReplyKey == replyKey;

                          void toggleSelect() {
                            setSheetState(() {
                              final controller = _replyControllers[username];
                              if (isSelected) {
                                selectedReplyKey = null;
                                if (controller != null) {
                                  controller.clear();
                                }
                              } else {
                                selectedReplyKey = replyKey;
                                if (controller != null) {
                                  controller.text = content;
                                  controller.selection =
                                      TextSelection.fromPosition(
                                        TextPosition(
                                          offset: controller.text.length,
                                        ),
                                      );
                                }
                              }
                            });
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            color: Theme.of(context).colorScheme.onSecondary,
                            child: ListTile(
                              onTap: toggleSelect,
                              leading: Radio<String>(
                                value: replyKey,
                                groupValue: selectedReplyKey,
                                toggleable: true,
                                onChanged: (_) => toggleSelect(),
                              ),
                              title: Text(content),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('$floor • $name'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主题讨论')),
      body: _isLoading
          ? const SafeArea(child: Center(child: CircularProgressIndicator()))
          : _error != null
          ? SafeArea(child: Center(child: Text(_error!)))
          : SafeArea(
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _discussionContent.isEmpty
                                  ? '（暂无讨论问题）'
                                  : _discussionContent,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.selectedUsernames.length,
                      itemBuilder: (context, index) {
                        final username = widget.selectedUsernames[index];
                        final controller = _replyControllers[username]!;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              _displayUsername(username),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: _isReplyLoading(username)
                                            ? null
                                            : () => _showReplyBottomSheet(
                                                username,
                                              ),
                                        child: Text(
                                          _isReplyLoading(username)
                                              ? '加载中...'
                                              : '使用他人回复',
                                        ),
                                      ),
                                      TextButton(
                                        onPressed:
                                            _canApplySameContent(username)
                                            ? () => _applyToAllUsers(username)
                                            : null,
                                        child: const Text('一键填入'),
                                      ),
                                    ],
                                  ),
                                  TextField(
                                    controller: controller,
                                    minLines: 2,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '请输入回复内容',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _submitReplies : null,
                        child: const Text('提交'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
