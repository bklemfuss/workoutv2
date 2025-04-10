import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformNavBar(
      currentIndex: currentIndex,
      itemChanged: (index) {
        _onTabTapped(context, index);
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle),
          label: 'Account',
        ),
      ],
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    final routes = [
      '/',           // Dashboard route
      '/history',    // History route
      '/statistics', // Statistics route
      '/options',    // Options route
    ];

    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }
}