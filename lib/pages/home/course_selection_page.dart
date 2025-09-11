import 'package:cxutils/providers/settings_provider.dart';
import 'package:cxutils/utils/course_logic.dart';
import 'package:flutter/material.dart';

class CourseSelectionPage extends StatefulWidget {
  final List<String> selectedUsernames;

  const CourseSelectionPage({super.key, required this.selectedUsernames});

  @override
  State<CourseSelectionPage> createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage> {
  late Future<Map<String, List<Course>>> _coursesFuture;
  final Map<String, Course> _selectedCourse = {};
  bool _showNextButton = false;
  late SettingsProvider _settings;

  @override
  void initState() {
    super.initState();
    _settings = SettingsProvider.instance;
    if (_settings.overrideCourseID.isEmpty ||
        _settings.overrideClassID.isEmpty) {
      _coursesFuture = fetchCoursesForUsers(widget.selectedUsernames);
    }
  }

  void _onCourseSelected(String username, Course? selectedCourse,
      Map<String, List<Course>> allCourses) {
    setState(() {
      if (selectedCourse != null) {
        // For multiple users, any selection change should trigger a sync attempt
        if (widget.selectedUsernames.length > 1) {
          final Map<String, Course> newSelections = {};
          bool allFound = true;

          // Try to find the selected course for all users
          for (var user in widget.selectedUsernames) {
            try {
              final matchingCourse = allCourses[user]!
                  .firstWhere((course) => course.name == selectedCourse.name);
              newSelections[user] = matchingCourse;
            } catch (e) {
              allFound = false;
              break; // Stop if any user doesn't have the course
            }
          }

          if (allFound) {
            _selectedCourse.clear();
            _selectedCourse.addAll(newSelections);
          } else {
            // If sync fails, show a message and revert to individual selection
            _selectedCourse.clear();
            _selectedCourse[username] = selectedCourse; // Keep only the current user's selection
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('部分用户找不到相同课程，请单独签到或更换课程')),
            );
          }
        } else {
          // For a single user, just update the selection
          _selectedCourse[username] = selectedCourse;
        }
      } else {
        // If a selection is cleared, clear all selections for multi-user case
        if (widget.selectedUsernames.length > 1) {
          _selectedCourse.clear();
        } else {
          _selectedCourse.remove(username);
        }
      }
      _checkIfAllSelected();
    });
  }

  void _checkIfAllSelected() {
    if (_selectedCourse.length == widget.selectedUsernames.length) {
      _showNextButton = true;
    } else {
      _showNextButton = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择课程'),
      ),
      body: SafeArea(
        child: _settings.overrideCourseID.isNotEmpty &&
                _settings.overrideClassID.isNotEmpty
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "已手动填入课程信息\n请直接点击下一步按钮",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final selectedCourseDetails = [
                        _settings.overrideCourseID,
                        _settings.overrideClassID
                      ];
                      print("selected users: ${widget.selectedUsernames}");
                      print("selected course details: $selectedCourseDetails");
                    },
                    child: const Text('下一步'),
                  )
                ],
              ))
            : FutureBuilder<Map<String, List<Course>>>(
                future: _coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('加载课程失败: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final allCourses = snapshot.data!;
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.selectedUsernames.length,
                            itemBuilder: (context, index) {
                              final username = widget.selectedUsernames[index];
                              final courses = allCourses[username] ?? [];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: ListTile(
                                  title: Text(
                                    '用户$username：',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: DropdownButton<Course>(
                                    isExpanded: true,
                                    hint: const Text('--请选择--'),
                                    value: _selectedCourse[username],
                                    onChanged: (Course? newValue) {
                                      _onCourseSelected(
                                          username, newValue, allCourses);
                                    },
                                    items: courses
                                        .map<DropdownMenuItem<Course>>(
                                            (Course course) {
                                      return DropdownMenuItem<Course>(
                                        value: course,
                                        child: Text(course.name),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (_showNextButton)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedCourse.isNotEmpty) {
                                  final firstCourse =
                                      _selectedCourse.values.first;
                                  final selectedCourseDetails = [
                                    firstCourse.courseId,
                                    firstCourse.classId
                                  ];
                                  print("selected users: ${widget.selectedUsernames}");
                                  print("selected course details: $selectedCourseDetails");
                                }
                              },
                              child: const Text('下一步'),
                            ),
                          ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('没有课程数据'));
                  }
                },
              ),
      ),
    );
  }
}
