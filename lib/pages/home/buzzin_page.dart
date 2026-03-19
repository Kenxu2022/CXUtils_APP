import 'dart:async';

import 'package:cxutils/network/api.dart' as api;
import 'package:cxutils/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuzzInPage extends StatefulWidget {
	final List<String> selectedUsernames;
	final List<String> selectedCourseDetails;
	final String selectedActiveID;

	const BuzzInPage({
		super.key,
		required this.selectedUsernames,
		required this.selectedCourseDetails,
		required this.selectedActiveID,
	});

	@override
	State<BuzzInPage> createState() => _BuzzInPageState();
}

class _BuzzInPageState extends State<BuzzInPage> {
	bool _isLoading = true;
	bool _isRefreshing = false;
	String? _error;
	String _startTime = '';
	String _endTime = '';
	bool _hasEnded = false;
	int _allowAnswerStuNum = 0;
	List<Map<String, dynamic>> _attendList = [];
	DateTime _currentTime = DateTime.now();
	Timer? _refreshTimer;
	final DateFormat _timeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

	@override
	void initState() {
		super.initState();
		_fetchBuzzIn();
		_refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
			if (!mounted) {
				return;
			}
			setState(() {
				_currentTime = DateTime.now();
			});
			if (_hasEnded) {
				return;
			}
			_fetchBuzzIn();
		});
	}

	@override
	void dispose() {
		_refreshTimer?.cancel();
		super.dispose();
	}

	Future<void> _fetchBuzzIn() async {
		if (_isRefreshing) {
			return;
		}
		_isRefreshing = true;
		try {
			final response = await api.getBuzzIn(
				widget.selectedUsernames.first,
				widget.selectedCourseDetails[0],
				widget.selectedCourseDetails[1],
				widget.selectedActiveID,
			);

			if (!mounted) {
				return;
			}

			if (response['success'] == true) {
				final data = Map<String, dynamic>.from(response['data']);
				final attendList = List<Map<String, dynamic>>.from(
					(data['attendList'] ?? []).map((item) => Map<String, dynamic>.from(item)),
				);
				final hasEnded = (data['hasEnded'] ?? false) as bool;
				setState(() {
					_startTime = (data['startTime'] ?? '').toString();
					_endTime = (data['endTime'] ?? '').toString();
					_hasEnded = hasEnded;
					_allowAnswerStuNum = (data['allowAnswerStuNum'] ?? 0) as int;
					_attendList = attendList;
					_currentTime = DateTime.now();
					_error = null;
					_isLoading = false;
				});
			} else {
				setState(() {
					_error = (response['data'] ?? '获取抢答信息失败').toString();
					_isLoading = false;
				});
			}
		} catch (e) {
			if (!mounted) {
				return;
			}
			setState(() {
				_error = '加载抢答信息失败: $e';
				_isLoading = false;
			});
		} finally {
			_isRefreshing = false;
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
		if (_isLoading) {
			return Scaffold(
				appBar: AppBar(title: const Text('抢答')),
				body: const SafeArea(child: Center(child: CircularProgressIndicator())),
			);
		}

		return Scaffold(
			appBar: AppBar(title: const Text('抢答')),
			body: SafeArea(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Card(
							margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
							child: Padding(
								padding: const EdgeInsets.symmetric(
									horizontal: 14,
									vertical: 12,
								),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											'开始时间：$_startTime',
											style: const TextStyle(fontSize: 16),
										),
										Text(
											'结束时间：$_endTime',
											style: const TextStyle(fontSize: 16),
										),
										Text(
											'状态：${_hasEnded ? '已结束' : '进行中'}',
											style: const TextStyle(fontSize: 16),
										),
										Text(
											'已抢答学生数量：${_attendList.length}',
											style: const TextStyle(fontSize: 16),
										),
										Text(
											'允许抢答的学生数量：${_allowAnswerStuNum == 0 ? '无限制' : _allowAnswerStuNum}',
											style: const TextStyle(fontSize: 16),
										),
									],
								),
							),
						),
						const Padding(
							padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
							child: Align(
								alignment: Alignment.centerLeft,
								child: Text('已经抢答的学生信息：（每三秒刷新）'),
							),
						),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
							child: Align(
								alignment: Alignment.centerLeft,
								child: Text('当前时间：${_timeFormatter.format(_currentTime)}'),
							),
						),
						if (_error != null)
							Padding(
								padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
								child: Text(
									_error!,
									style: const TextStyle(color: Colors.red),
								),
							),
						Expanded(
							child: _attendList.isEmpty
									? const Center(child: Text('暂无抢答记录'))
									: ListView.builder(
											itemCount: _attendList.length,
											itemBuilder: (context, index) {
												final item = _attendList[index];
												final name = (item['name'] ?? '').toString();
												final answerTime = (item['answerTime'] ?? '').toString();
												return Card(
													margin: const EdgeInsets.symmetric(
														horizontal: 12,
														vertical: 6,
													),
													color: Theme.of(context).colorScheme.onSecondary,
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(12),
													),
													clipBehavior: Clip.antiAlias,
													child: ListTile(
														title: Text('${index + 1}. $name'),
														subtitle: Padding(
															padding: const EdgeInsets.only(top: 6),
															child: Text('抢答时间：$answerTime'),
														),
													),
												);
											},
										),
						),
						Padding(
							padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
							child: Center(
								child: ElevatedButton(onPressed: _goHome, child: const Text('返回主页')),
							),
						),
					],
				),
			),
		);
	}
}
