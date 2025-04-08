import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'History Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}