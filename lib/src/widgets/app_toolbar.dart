import 'package:flutter/material.dart';

class AppToolbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppToolbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Placeholder logo on the left
          Row(
            children: [
              const Icon(Icons.fitness_center, size: 28), // Placeholder logo
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 20)),
            ],
          ),
          // Profile picture on the right
          GestureDetector(
            onTap: () {
              _showProfileMenu(context);
            },
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/flutter_logo.png'), // Replace with profile image
              radius: 18,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
    );
  }

  void _showProfileMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 10, 0),
      items: [
        const PopupMenuItem(
          value: 'profile',
          child: Text('Profile'),
        ),
        const PopupMenuItem(
          value: 'signout',
          child: Text('Sign out'),
        ),
      ],
    ).then((value) {
      if (value == 'profile') {
        // Navigate to Profile screen
        Navigator.pushNamed(context, '/profile');
      } else if (value == 'signout') {
        // Handle sign-out logic
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}