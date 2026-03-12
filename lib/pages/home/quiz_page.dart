import 'package:flutter/material.dart';
import 'package:cxutils/network/api.dart' as api;
import 'package:cxutils/utils/quiz_logic.dart' as quiz_logic;

class QuizPage extends StatefulWidget {
  final List<String> selectedUsernames;
  final List<String> selectedCourseDetails;
  final String selectedActiveID;

  const QuizPage({
    super.key,
    required this.selectedUsernames,
    required this.selectedCourseDetails,
    required this.selectedActiveID,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static const String _imageUserAgent =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36';

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _questions = [];

  final Map<int, String> _singleChoiceAnswers = {};
  final Map<int, Set<String>> _multipleChoiceAnswers = {};
  final Map<int, String> _judgementAnswers = {};
  final Map<int, Map<String, TextEditingController>> _blankAnswers = {};
  final Map<int, TextEditingController> _essayAnswers = {};

  @override
  void initState() {
    super.initState();
    _fetchQuizDetail();
  }

  @override
  void dispose() {
    for (final answerControllers in _blankAnswers.values) {
      for (final controller in answerControllers.values) {
        controller.dispose();
      }
    }
    for (final controller in _essayAnswers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchQuizDetail() async {
    try {
      final response = await api.getQuizDetail(
        widget.selectedUsernames.first,
        widget.selectedActiveID,
      );

      if (response['success'] == true) {
        final questions = List<Map<String, dynamic>>.from(response['data']);
        quiz_logic.initializeQuizAnswerStates(
          questions: questions,
          blankAnswers: _blankAnswers,
          essayAnswers: _essayAnswers,
        );
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '${response['data']}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '加载问题失败: $e';
        _isLoading = false;
      });
    }
  }

  bool get _allAnswered {
    return quiz_logic.areAllQuizQuestionsAnswered(
      questions: _questions,
      singleChoiceAnswers: _singleChoiceAnswers,
      multipleChoiceAnswers: _multipleChoiceAnswers,
      judgementAnswers: _judgementAnswers,
      blankAnswers: _blankAnswers,
      essayAnswers: _essayAnswers,
    );
  }

  List<Widget> _buildResourceImages(Map<String, dynamic> question) {
    final resourceUrl = question['resourceUrl'];
    if (resourceUrl is! List || resourceUrl.isEmpty) {
      return const [];
    }
    final urls = resourceUrl.map((e) => '$e').toList();
    return urls
        .map(
          (url) => Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                headers: const {'User-Agent': _imageUserAgent},
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '图片加载失败',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildSingleChoice(int index, Map<String, dynamic> question) {
    final options = Map<String, dynamic>.from(question['options'] ?? {});
    return Column(
      children: options.entries
          .map(
            (entry) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Radio<String>(
                value: entry.key,
                groupValue: _singleChoiceAnswers[index],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _singleChoiceAnswers[index] = value;
                  });
                },
              ),
              title: Text('${entry.key}. ${entry.value}'),
              onTap: () {
                setState(() {
                  _singleChoiceAnswers[index] = entry.key;
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildMultipleChoice(int index, Map<String, dynamic> question) {
    final options = Map<String, dynamic>.from(question['options'] ?? {});
    final selected = _multipleChoiceAnswers.putIfAbsent(
      index,
      () => <String>{},
    );
    return Column(
      children: options.entries
          .map(
            (entry) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Checkbox(
                value: selected.contains(entry.key),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selected.add(entry.key);
                    } else {
                      selected.remove(entry.key);
                    }
                  });
                },
              ),
              title: Text('${entry.key}. ${entry.value}'),
              onTap: () {
                setState(() {
                  if (selected.contains(entry.key)) {
                    selected.remove(entry.key);
                  } else {
                    selected.add(entry.key);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildJudgement(int index) {
    final selected = _judgementAnswers[index];
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Radio<String>(
            value: '1',
            groupValue: selected,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _judgementAnswers[index] = value;
              });
            },
          ),
          title: const Text('正确'),
          onTap: () {
            setState(() {
              _judgementAnswers[index] = '1';
            });
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Radio<String>(
            value: '2',
            groupValue: selected,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _judgementAnswers[index] = value;
              });
            },
          ),
          title: const Text('错误'),
          onTap: () {
            setState(() {
              _judgementAnswers[index] = '2';
            });
          },
        ),
      ],
    );
  }

  Widget _buildFillBlank(int index, Map<String, dynamic> question) {
    final controllers = _blankAnswers[index];
    if (controllers == null || controllers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: controllers.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: entry.value,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: '空 ${entry.key}',
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEssay(int index) {
    final controller = _essayAnswers[index];
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: 6,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '请输入答案',
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildQuestionBody(int index, Map<String, dynamic> question) {
    final type = question['type'] as int;
    if (type == 0) {
      return _buildSingleChoice(index, question);
    }
    if (type == 1) {
      return _buildMultipleChoice(index, question);
    }
    if (type == 16) {
      return _buildJudgement(index);
    }
    if (type == 2) {
      return _buildFillBlank(index, question);
    }
    if (type == 4) {
      return _buildEssay(index);
    }
    return const Padding(padding: EdgeInsets.all(16), child: Text('暂不支持的题型'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('回答问题')),
      body: _isLoading
          ? const SafeArea(child: Center(child: CircularProgressIndicator()))
          : _error != null
          ? SafeArea(child: Center(child: Text(_error!)))
          : _questions.isEmpty
          ? const SafeArea(child: Center(child: Text('暂无问题')))
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final type = question['type'] as int;
                  final answered = quiz_logic.isQuizQuestionAnswered(
                    index: index,
                    question: question,
                    singleChoiceAnswers: _singleChoiceAnswers,
                    multipleChoiceAnswers: _multipleChoiceAnswers,
                    judgementAnswers: _judgementAnswers,
                    blankAnswers: _blankAnswers,
                    essayAnswers: _essayAnswers,
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text('第${index + 1}题  ${question['title']}'),
                          subtitle: Text(quiz_logic.quizTypeLabel(type)),
                          trailing: Icon(
                            answered
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: answered
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                          ),
                        ),
                        ..._buildResourceImages(question),
                        _buildQuestionBody(index, question),
                      ],
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _allAnswered
                    ? () {
                        // TODO: add submit behavior.
                      }
                    : null,
                child: const Text('提交'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
