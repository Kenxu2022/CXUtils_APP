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
  final userCourses = <String, List<Course>>{};
  final futures = usernames.map((username) => getCourse(username)).toList();

  final results = await Future.wait(futures);

  for (int i = 0; i < results.length; i++) {
    final result = results[i];
    final username = usernames[i];

    if (result['success']) {
      final List<dynamic> courseData = result['data'];
      userCourses[username] =
          courseData.map((data) => Course.fromJson(data)).toList();
    } else {
      throw Exception(
          'Failed to load courses for $username: ${result['data']}');
    }
  }

  return userCourses;
}

