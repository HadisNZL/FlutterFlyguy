import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('调试信息${DateTime.now()}');
    print('普通信息${DateTime.now()}');
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('你好世界我的世界牛逼呵呵'))),
    );
  }
}
