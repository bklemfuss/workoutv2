import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Statistics Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}