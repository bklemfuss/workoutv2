import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        _onTabTapped(context, index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center), // <-- New Exercises tab icon
          label: 'Exercises',                // <-- New Exercises tab label
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Options',
        ),
      ],
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    final routes = [
      '/',           // Dashboard route
      '/history',    // History route
      '/statistics', // Statistics route
      '/exercises',  // <-- New Exercises route
      '/options',    // Options route
    ];

    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }
}