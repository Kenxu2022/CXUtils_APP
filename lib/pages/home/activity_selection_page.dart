import 'package:flutter/material.dart';
import 'package:cxutils/network/api.dart' as api;
import 'package:cxutils/pages/home/signin_page.dart';
import 'package:cxutils/pages/home/quiz_page.dart';

class ActivitySelectionPage extends StatefulWidget {
  final List<String> selectedUsernames;
  final List<String> selectedCourseDetails;

  const ActivitySelectionPage({
    super.key,
    required this.selectedUsernames,
    required this.selectedCourseDetails,
  });

  @override
  State<ActivitySelectionPage> createState() => _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends State<ActivitySelectionPage> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;
  String? _error;
  List<dynamic>? _selectedActivityValue;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    try {
      final response = await api.getActivity(
        widget.selectedUsernames.first,
        widget.selectedCourseDetails[0],
        widget.selectedCourseDetails[1],
      );
      if (response['success']) {
        final activities = List<Map<String, dynamic>>.from(response['data']);
        for (final activity in activities) {
          activity['_selectionValue'] = [
            activity['activeType'],
            activity['activeID'].toString(),
          ];
        }

        setState(() {
          _activities = activities;
          if (_activities.isNotEmpty) {
            _selectedActivityValue = _activities.first['_selectionValue'];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '加载活动失败: $e';
        _isLoading = false;
      });
    }
  }

  Color _activityBackgroundColor(int activeType, ColorScheme colorScheme) {
    if (activeType == 2) {
      return Colors.lightBlue.withValues(alpha: 0.15);
    }
    if (activeType == 42) {
      return Colors.red.withValues(alpha: 0.12);
    }
    return colorScheme.surface;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('选择活动')),
      body: _isLoading
          ? const SafeArea(child: Center(child: CircularProgressIndicator()))
          : _error != null
          ? SafeArea(child: Center(child: Text(_error!)))
          : _activities.isEmpty
          ? SafeArea(child: Center(child: Text('没有可用的活动')))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        final activeType = activity['activeType'] as int;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8.0,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: _activityBackgroundColor(
                              activeType,
                              colorScheme,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Radio<List<dynamic>>(
                              value: activity['_selectionValue'],
                              groupValue: _selectedActivityValue,
                              onChanged: (List<dynamic>? value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedActivityValue = value;
                                });
                              },
                            ),
                            title: Text(activity['name']),
                            subtitle: Text(
                              '开始: ${activity['startTime']}\n结束: ${activity['endTime']}',
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
                        onPressed: () {
                          if (_selectedActivityValue == null) {
                            return;
                          }
                          final activeType = _selectedActivityValue![0] as int;
                          final selectedActiveID =
                              _selectedActivityValue![1] as String;

                          if (activeType == 2) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignInPage(
                                  selectedUsernames: widget.selectedUsernames,
                                  selectedCourseDetails:
                                      widget.selectedCourseDetails,
                                  selectedActiveID: selectedActiveID,
                                ),
                              ),
                            );
                            return;
                          }

                          if (activeType == 42) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizPage(
                                  selectedUsernames: widget.selectedUsernames,
                                  selectedCourseDetails:
                                      widget.selectedCourseDetails,
                                  selectedActiveID: selectedActiveID,
                                ),
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('暂不支持的活动类型: $activeType')),
                          );
                        },
                        child: const Text('下一步'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
