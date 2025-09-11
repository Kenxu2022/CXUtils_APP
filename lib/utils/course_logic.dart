import 'package:cxutils/network/api.dart';

class Course {
  final String name;
  final String teacher;
  final String courseId;
  final String classId;

  Course(
      {required this.name,
      required this.teacher,
      required this.courseId,
      required this.classId});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name'],
      teacher: json['teacher'],
      courseId: json['courseID'].toString(),
      classId: json['classID'].toString(),
    );
  }
}

Future<Map<String, List<Course>>> fetchCoursesForUsers(
    List<String> usernames) async {
  Map<String, List<Course>> userCourses = {};
  for (String username in usernames) {
    final result = await getCourse(username);
    if (result['success']) {
      final List<dynamic> courseData = result['data'];
      userCourses[username] =
          courseData.map((data) => Course.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load courses for $username: ${result['data']}');
    }
  }
  return userCourses;
}

