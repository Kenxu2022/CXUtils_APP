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
  final Map<String, Course> _selectedCourses = {};
  bool _showNextButton = false;

  @override
  void initState() {
    super.initState();
    _coursesFuture = fetchCoursesForUsers(widget.selectedUsernames);
  }

  void _onCourseSelected(String username, Course? selectedCourse,
      Map<String, List<Course>> allCourses) {
    setState(() {
      if (selectedCourse != null) {
        _selectedCourses[username] = selectedCourse;

        // Auto-select for other users if this is the first selection
        if (widget.selectedUsernames.length > 1 &&
            _selectedCourses.length == 1) {
          bool allFound = true;
          for (var otherUser in widget.selectedUsernames) {
            if (otherUser == username) continue;
            try {
              final matchingCourse = allCourses[otherUser]!
                  .firstWhere((course) => course.name == selectedCourse.name);
              _selectedCourses[otherUser] = matchingCourse;
            } catch (e) {
              allFound = false;
            }
          }
          if (!allFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('找不到相同的课程，请单独签到')),
            );
            // Clear selection because auto-selection failed
            _selectedCourses.clear();
          }
        }
      } else {
        _selectedCourses.remove(username);
      }
      _checkIfAllSelected();
    });
  }

  void _checkIfAllSelected() {
    if (_selectedCourses.length == widget.selectedUsernames.length) {
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
        child: FutureBuilder<Map<String, List<Course>>>(
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: DropdownButton<Course>(
                              isExpanded: true,
                              hint: const Text('--请选择--'),
                              value: _selectedCourses[username],
                              onChanged: (Course? newValue) {
                                _onCourseSelected(
                                    username, newValue, allCourses);
                              },
                              items: courses.map<DropdownMenuItem<Course>>(
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
                          //  留空
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
