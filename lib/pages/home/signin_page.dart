import 'package:flutter/material.dart';
import 'package:cxutils/network/api.dart' as api;
import 'package:cxutils/pages/home/home_page.dart';
import 'package:cxutils/utils/signin_logic.dart';
import 'package:cxutils/pages/home/signcode_input_page.dart';

class SignInPage extends StatefulWidget {
  final List<String> selectedUsernames;
  final List<String> selectedCourseDetails;
  final String selectedActiveID;

  const SignInPage({
    super.key,
    required this.selectedUsernames,
    required this.selectedCourseDetails,
    required this.selectedActiveID,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _signInDetail;
  List<String> fetchedValidateCode = [];
  // signin result
  bool? _signInOverallSuccess;
  String? _signInErrorData;
  List<Map<String, dynamic>> _signInResults = []; // results for each user
  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  Future<void> _initFetch() async {
    try {
      final detailResp = await api.getSignInDetail(
        widget.selectedUsernames.first,
        widget.selectedActiveID,
      );
      if (detailResp['success'] != true) {
        setState(() {
          _error = detailResp['detail']?.toString() ?? '获取签到详情失败';
          _loading = false;
        });
        return;
      }

      final Map<String, dynamic> detail =
          Map<String, dynamic>.from(detailResp['detail']);

      // parallel request validate code if required
      if (detail['needValidation'] == true) {
        try {
          final futures = widget.selectedUsernames.map(
            (u) => api.getValidateCode(
              u,
              widget.selectedCourseDetails[0],
              widget.selectedCourseDetails[1],
              widget.selectedActiveID,
            ),
          );
          final responses = await Future.wait(futures);
          fetchedValidateCode = responses
              .map(
                (r) => r['success'] == true
                    ? (r['code']?.toString() ?? '')
                    : (r['code']?.toString() ?? '获取失败'),
              )
              .toList(growable: false);
        } catch (e) {
            fetchedValidateCode = List.generate(
              widget.selectedUsernames.length,
              (_) => '异常:$e',
            );
        }
      }
      // prepare signCode for type 3/5 by navigating to input page
      final int type = detail['type'];
      String? signCode;
      if (type == 3 || type == 5) {
        signCode = await Navigator.of(context).push<String>(
          MaterialPageRoute(builder: (_) => const SigncodeInputPage()),
        );
        if (signCode == null || signCode.isEmpty) {
          setState(() {
            _error = '未输入签到码，已取消';
            _loading = false;
          });
          return;
        }
      }

      // perform sign-in
      final results = await signInAll(
        type,
        widget.selectedUsernames,
        widget.selectedActiveID,
        validateCodes: detail['needValidation'] == true ? fetchedValidateCode : null,
        signCode: signCode,
      );
      final overallSuccess = results.every((r) => r['success'] == true);
      String? errorData;
      if (!overallSuccess) {
        errorData = results
            .where((r) => r['success'] != true)
            .map((r) => '${r['username']}: ${r['detail'] ?? '未知错误'}')
            .join('\n');
      }

      setState(() {
        _signInDetail = detail;
        _signInResults = results;
        _signInOverallSuccess = overallSuccess;
        _signInErrorData = errorData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('签到')),
      body: SafeArea(
        child: Center(
          child: _loading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('读取签到活动信息'),
                  ],
                )
              : _error != null
                  ? _buildLoadError()
                  : _buildResult(),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final success = _signInOverallSuccess == true;
    final icon = success ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final color = success ? Colors.green : Colors.red;
    final text = success ? '签到成功！' : '签到失败！';
    final successCount = _signInResults.where((r) => r['success'] == true).length;
    final total = _signInResults.length;
    final type = _signInDetail?['type'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 72),
        const SizedBox(height: 16),
        Text(
          text,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        if (type != null) ...[
          const SizedBox(height: 4),
          Text('类型: $type', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
        if (total > 1) ...[
          const SizedBox(height: 8),
          Text('成功: $successCount / $total', style: TextStyle(color: color, fontSize: 14)),
        ],
        if (!success && _signInErrorData != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _signInErrorData!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.redAccent),
            ),
          ),
        ],
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          },
          child: const Text('返回主页'),
        ),
      ],
    );
  }

  Widget _buildLoadError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 72, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          _error ?? '未知错误',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          },
          child: const Text('返回主页'),
        ),
      ],
    );
  }
}
