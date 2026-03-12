import 'package:flutter/material.dart';

/* quiz problem submission format:
use passed-in originalData and ONLY modify "personAnswer" key (originalData[i].personAnswer) according to the following format:
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

void initializeQuizAnswerStates({
  required List<Map<String, dynamic>> questions,
  required Map<int, Map<String, TextEditingController>> blankAnswers,
  required Map<int, TextEditingController> essayAnswers,
}) {
  for (var i = 0; i < questions.length; i++) {
    final type = questions[i]['type'] as int;
    if (type == 2) {
      final blankNames = extractBlankNames(questions[i]);
      final controllers = <String, TextEditingController>{};
      for (final name in blankNames) {
        controllers[name] = TextEditingController();
      }
      blankAnswers[i] = controllers;
    }

    if (type == 4) {
      essayAnswers[i] = TextEditingController();
    }
  }
}

List<String> extractBlankNames(Map<String, dynamic> question) {
  final options = question['options'] as Map;
  return options.keys.map((k) => '$k').toList();
}

bool isQuizQuestionAnswered({
  required int index,
  required Map<String, dynamic> question,
  required Map<int, String> singleChoiceAnswers,
  required Map<int, Set<String>> multipleChoiceAnswers,
  required Map<int, String> judgementAnswers,
  required Map<int, Map<String, TextEditingController>> blankAnswers,
  required Map<int, TextEditingController> essayAnswers,
}) {
  final type = question['type'] as int;
  if (type == 0) {
    return (singleChoiceAnswers[index] ?? '').isNotEmpty;
  }
  if (type == 1) {
    return (multipleChoiceAnswers[index] ?? <String>{}).isNotEmpty;
  }
  if (type == 16) {
    return (judgementAnswers[index] ?? '').isNotEmpty;
  }
  if (type == 2) {
    final controllers = blankAnswers[index];
    if (controllers == null || controllers.isEmpty) {
      return false;
    }
    return controllers.values.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
  }
  if (type == 4) {
    final controller = essayAnswers[index];
    return controller != null && controller.text.trim().isNotEmpty;
  }
  return false;
}

bool areAllQuizQuestionsAnswered({
  required List<Map<String, dynamic>> questions,
  required Map<int, String> singleChoiceAnswers,
  required Map<int, Set<String>> multipleChoiceAnswers,
  required Map<int, String> judgementAnswers,
  required Map<int, Map<String, TextEditingController>> blankAnswers,
  required Map<int, TextEditingController> essayAnswers,
}) {
  if (questions.isEmpty) {
    return false;
  }

  for (var i = 0; i < questions.length; i++) {
    if (!isQuizQuestionAnswered(
      index: i,
      question: questions[i],
      singleChoiceAnswers: singleChoiceAnswers,
      multipleChoiceAnswers: multipleChoiceAnswers,
      judgementAnswers: judgementAnswers,
      blankAnswers: blankAnswers,
      essayAnswers: essayAnswers,
    )) {
      return false;
    }
  }
  return true;
}

String quizTypeLabel(int type) {
  if (type == 0) return '单选题';
  if (type == 1) return '多选题';
  if (type == 2) return '填空题';
  if (type == 4) return '简答题';
  if (type == 16) return '判断题';
  return '未知题型';
}
