import 'package:flutter/material.dart';

class AppToolbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppToolbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme
    final appBarTheme = theme.appBarTheme; // Access the AppBar theme

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Placeholder logo on the left
          Row(
            children: [
              Icon(Icons.fitness_center, size: 28, color: appBarTheme.foregroundColor), // Use theme color
              const SizedBox(width: 8),
              Text(
                title,
                style: appBarTheme.titleTextStyle ?? // Use theme title style
                    TextStyle(
                      fontSize: 20,
                      color: appBarTheme.foregroundColor, // Fallback to theme color
                    ),
              ),
            ],
          ),
          // Profile picture on the right
          GestureDetector(
            onTap: () {
              _showProfileMenu(context);
            },
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/images/flutter_logo.png'), // Replace with profile image
              radius: 18,
              backgroundColor: theme.colorScheme.surface, // Use surface color for avatar background
            ),
          ),
        ],
      ),
      backgroundColor: appBarTheme.backgroundColor, // Use theme background color
      elevation: appBarTheme.elevation ?? 4, // Use theme elevation
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