import 'package:cxutils/network/api.dart' as api;
import 'package:cxutils/pages/home/home_page.dart';
import 'package:flutter/material.dart';

class DiscussionSubmissionPage extends StatefulWidget {
  final List<String> usernames;
  final String courseID;
  final String classID;
  final String uuid;
  final String bbsid;
  final Map<String, String> replyContents;

  const DiscussionSubmissionPage({
    super.key,
    required this.usernames,
    required this.courseID,
    required this.classID,
    required this.uuid,
    required this.bbsid,
    required this.replyContents,
  });

  @override
  State<DiscussionSubmissionPage> createState() =>
      _DiscussionSubmissionPageState();
}

class _DiscussionSubmissionPageState extends State<DiscussionSubmissionPage> {
  bool _isSubmitting = true;
  bool _isSuccess = false;
  int _successCount = 0;
  int _total = 0;
  Map<String, String>? _errorData;

  @override
  void initState() {
    super.initState();
    _submitReplies();
  }

  Future<void> _submitReplies() async {
    try {
      final responses = await Future.wait(
        widget.usernames.map(
          (username) => api.submitReply(
            username,
            widget.courseID,
            widget.classID,
            widget.uuid,
            widget.bbsid,
            widget.replyContents[username] ?? '',
          ),
        ),
      );

      final failures = <String, String>{};
      var successCount = 0;

      for (var i = 0; i < responses.length; i++) {
        final response = responses[i];
        if (response['success'] == true) {
          successCount++;
        } else {
          failures[widget.usernames[i]] = '${response['detail'] ?? '未知错误'}';
        }
      }

      setState(() {
        _isSuccess = failures.isEmpty;
        _successCount = successCount;
        _total = responses.length;
        _errorData = failures.isEmpty ? null : failures;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _successCount = 0;
        _total = widget.usernames.length;
        _errorData = {'系统': '提交异常: $e'};
        _isSubmitting = false;
      });
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return Scaffold(
        appBar: AppBar(title: const Text('提交讨论')),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final color = _isSuccess ? Colors.green : Colors.red;
    final icon = _isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final text = _isSuccess ? '提交成功' : '提交失败';

    return Scaffold(
      appBar: AppBar(title: const Text('提交讨论')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 72, color: color),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (_total > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    '成功: $_successCount / $_total',
                    style: TextStyle(color: color, fontSize: 14),
                  ),
                ],
                if (!_isSuccess && _errorData != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _errorData!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                ElevatedButton(onPressed: _goHome, child: const Text('返回主页')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
