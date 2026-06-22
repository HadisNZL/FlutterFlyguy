import 'package:flutter/material.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('记录页面 - 占位'),
      ),
    );
  }
}
