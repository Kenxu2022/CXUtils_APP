import 'package:flutter/material.dart';

class SigncodeInputPage extends StatefulWidget {
	const SigncodeInputPage({super.key});

	@override
	State<SigncodeInputPage> createState() => _SigncodeInputPageState();
}

class _SigncodeInputPageState extends State<SigncodeInputPage> {
	String _input = '';

	void _append(String digit) {
		setState(() => _input += digit);
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;
		final btnStyle = ElevatedButton.styleFrom(
			backgroundColor: colorScheme.primary,
			foregroundColor: colorScheme.onPrimary,
			shape: const CircleBorder(),
			padding: const EdgeInsets.all(18),
		);

		Widget numBtn(String d, {EdgeInsets margin = const EdgeInsets.all(8)}) {
			return Container(
				margin: margin,
				child: ElevatedButton(
					style: btnStyle,
					onPressed: () => _append(d),
					child: Text(d, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
				),
			);
		}

		return Scaffold(
			appBar: AppBar(title: const Text('输入签到码')),
			body: SafeArea(
				child: Center(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
							const Text(
								'请输入签到码\n若为手势签到，请按照划线顺序依次输入数字',
								textAlign: TextAlign.center,
							),
							const SizedBox(height: 16),
							Container(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
								decoration: BoxDecoration(
									color: colorScheme.surfaceVariant,
									borderRadius: BorderRadius.circular(8),
								),
								child: Text(
									_input.isEmpty ? ' ' : _input,
									style: const TextStyle(fontSize: 22, letterSpacing: 2),
								),
							),
							const SizedBox(height: 24),
							// keypad
							Column(
								children: [
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [numBtn('1'), numBtn('2'), numBtn('3')],
									),
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [numBtn('4'), numBtn('5'), numBtn('6')],
									),
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [numBtn('7'), numBtn('8'), numBtn('9')],
									),
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											numBtn('0'),
											Container(
												margin: const EdgeInsets.all(8),
												child: ElevatedButton(
													style: btnStyle,
													onPressed: _input.isEmpty
															? null
															: () {
																	setState(() {
																		_input = _input.substring(0, _input.length - 1);
																	});
																},
													child: const Icon(Icons.backspace_rounded, size: 20),
												),
											),
										],
									),
								],
							),
							const SizedBox(height: 28),
							ElevatedButton(
								style: ElevatedButton.styleFrom(
									backgroundColor: colorScheme.primary,
									foregroundColor: colorScheme.onPrimary,
									padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
								),
								onPressed: _input.isEmpty
										? null
										: () {
												Navigator.of(context).pop(_input);
											},
								child: const Text('确认', style: TextStyle(fontSize: 16)),
							),
						],
					),
				),
			),
		);
	}
}
