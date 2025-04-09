import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'Account'),
      body: const Center(
        child: Text(
          'This is the Account Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 3, // Index for Account
      ),
    );
  }
}