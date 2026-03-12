import 'package:cxutils/network/api.dart' as api;
import 'package:cxutils/pages/home/home_page.dart';
import 'package:flutter/material.dart';

/* quiz problem submission format:
use passed-in originalData (from response['originalData']) and ONLY modify value of "personAnswer" key (originalData[i].personAnswer) according to the following format:
single choice (type == 0):
{
  "myoption": "A"
}
multiple choice (type == 1):
{
  "myoption": "AB"
}
fill in the blank (type == 2): 
{
  "blankAnswer": [
    {
      "name": "A", --> option name in data[i].options
      "content": "xxx"
    },
    {
      "name": "B",
      "content": "xxx"
    },
    ...
  ]
}
essay (type == 4):
{
  "content": "xxx",
  "recs": [] --> leave it blank
}
judgement (type == 16):
{
  "myoption": "2" // 1 == true, 2 == false
}
*/

class QuizSubmissionPage extends StatefulWidget {
  final List<String> usernames;
  final String courseID;
  final String classID;
  final String activeID;
  final List<Map<String, dynamic>> questions;
  final List<Map<String, dynamic>> originalData;
  final Map<int, String> singleChoiceAnswers;
  final Map<int, Set<String>> multipleChoiceAnswers;
  final Map<int, String> judgementAnswers;
  final Map<int, Map<String, String>> blankAnswers;
  final Map<int, String> essayAnswers;

  const QuizSubmissionPage({
    super.key,
    required this.usernames,
    required this.courseID,
    required this.classID,
    required this.activeID,
    required this.questions,
    required this.originalData,
    required this.singleChoiceAnswers,
    required this.multipleChoiceAnswers,
    required this.judgementAnswers,
    required this.blankAnswers,
    required this.essayAnswers,
  });

  @override
  State<QuizSubmissionPage> createState() => _QuizSubmissionPageState();
}

class _QuizSubmissionPageState extends State<QuizSubmissionPage> {
  bool _isSubmitting = true;
  bool _isSuccess = false;
  int _successCount = 0;
  int _total = 0;
  Map<String, String>? _errorData;

  @override
  void initState() {
    super.initState();
    _submitQuiz();
  }

  Future<void> _submitQuiz() async {
    try {
      final data = _buildSubmissionData();
      final responses = await Future.wait(
        widget.usernames.map(
          (username) => api.submitQuizProblem(
            username,
            widget.courseID,
            widget.classID,
            widget.activeID,
            data,
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

  List<Map<String, dynamic>> _buildSubmissionData() {
    final result = <Map<String, dynamic>>[];

    for (var i = 0; i < widget.originalData.length; i++) {
      final original = Map<String, dynamic>.from(widget.originalData[i]);
      final question = widget.questions[i];
      final type = question['type'] as int;

      if (type == 0) {
        original['personAnswer'] = {
          'myoption': widget.singleChoiceAnswers[i] ?? '',
        };
      } else if (type == 1) {
        final selected =
            (widget.multipleChoiceAnswers[i] ?? <String>{}).toList()..sort();
        original['personAnswer'] = {'myoption': selected.join()};
      } else if (type == 2) {
        final optionNames = (question['options'] as Map).keys
            .map((key) => '$key')
            .toList();
        final blankAnswer = optionNames
            .map(
              (name) => {
                'name': name,
                'content': widget.blankAnswers[i]?[name] ?? '',
              },
            )
            .toList();
        original['personAnswer'] = {'blankAnswer': blankAnswer};
      } else if (type == 4) {
        original['personAnswer'] = {
          'content': widget.essayAnswers[i] ?? '',
          'recs': <dynamic>[],
        };
      } else if (type == 16) {
        original['personAnswer'] = {
          'myoption': widget.judgementAnswers[i] ?? '',
        };
      }

      result.add(original);
    }

    return result;
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
        appBar: AppBar(title: const Text('提交答题')),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final color = _isSuccess ? Colors.green : Colors.red;
    final icon = _isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final text = _isSuccess ? '提交成功' : '提交失败';

    return Scaffold(
      appBar: AppBar(title: const Text('提交答题')),
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
