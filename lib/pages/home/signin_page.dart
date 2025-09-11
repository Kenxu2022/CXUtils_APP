import 'package:flutter/material.dart';
import 'package:cxutils/network/api.dart' as api;

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

      // use different signin api function based on type
      final type = detail['type'];
      if (type == 0) { // normal
        print('签到类型: 0 (普通)');
      } else if (type == 2) { // qrcode
        print('签到类型: 2 (二维码)');
      } else if (type == 4) { // location
        print('签到类型: 4 (定位)');
      } else if (type == 3 || type == 5) { // gesture | signcode
        print('签到类型: $type (手势/签到码 合并类型)');
      } else {
        print('未知签到类型: $type');
      }

      setState(() {
        _signInDetail = detail;
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
      body: Center(
        child: _loading
            ? SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                  Text('读取签到活动信息'),
                ],
              ))
            : _error != null
                ? Text(_error!)
                : SafeArea(child: _buildResult()),
      ),
    );
  }

  Widget _buildResult() {
    final type = _signInDetail?['type'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('类型: $type'),
          const SizedBox(height: 8),
          Text('需要验证: ${_signInDetail?['needValidation']}'),
          if (fetchedValidateCode.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('验证码列表:'),
            for (int i = 0; i < fetchedValidateCode.length; i++)
              Text('${widget.selectedUsernames[i]} -> ${fetchedValidateCode[i]}'),
          ],
          const SizedBox(height: 24),
          const Text('（后续签到逻辑待实现）'),
        ],
      ),
    );
  }
}
