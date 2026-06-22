import 'package:flutter/material.dart';

class GuardPage extends StatelessWidget {
  const GuardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('守护模式'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('守护模式页面 - 占位'),
      ),
    );
  }
}
