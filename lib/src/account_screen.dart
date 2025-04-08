import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Account Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}