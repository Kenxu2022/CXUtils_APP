import 'package:flutter/material.dart';
import 'package:cxutils/network/api.dart' as api;

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
  String? _selectedActiveID;

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
      print(response['data']);
      if (response['success']) {
        setState(() {
          _activities = List<Map<String, dynamic>>.from(response['data']);
          if (_activities.isNotEmpty) {
            _selectedActiveID = _activities.first['activeID'].toString();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择活动'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _activities.isEmpty
                  ? Center(child: Text('没有可用的活动'))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _activities.length,
                            itemBuilder: (context, index) {
                          final activity = _activities[index];
                          return Container(
                            color: colorScheme.surface,
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            child: ListTile(
                              leading: Radio<String>(
                                value: activity['activeID'].toString(),
                                groupValue: _selectedActiveID,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedActiveID = value;
                                  });
                                },
                              ),
                              title: Text(activity['name']),
                              subtitle: Text(
                                  '开始: ${activity['startTime']} - 结束: ${activity['endTime']}'),
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
                            // 之后的逻辑暂时留空
                            if (_selectedActiveID != null) {
                              // ignore: avoid_print
                              print('Selected Active ID: $_selectedActiveID');
                            }
                          },
                          child: const Text('下一步'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
