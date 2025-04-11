import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await DatabaseHelper().getUserById(1); // Fetch user with user_id = 1
    setState(() {
      user = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const AppToolbar(title: 'Account'),
      body: user.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Section (15% of the screen height)
                Container(
                  height: screenHeight * 0.15,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  color: Colors.blue[100], // Optional background color
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // User's Name on the Left
                      Expanded(
                        child: Text(
                          user['name'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: screenHeight * 0.03, // Dynamic font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Profile Picture on the Right
                      CircleAvatar(
                        radius: screenHeight * 0.05, // Dynamic radius
                        backgroundImage: user['profile_picture'] != null
                            ? NetworkImage(user['profile_picture'])
                            : const AssetImage('assets/images/flutter_logo.png') as ImageProvider,
                      ),
                    ],
                  ),
                ),
                // Bottom Section (85% of the screen height)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Height: ${user['height'] ?? 'N/A'} cm',
                          style: TextStyle(fontSize: screenHeight * 0.02),
                        ),
                        SizedBox(height: screenHeight * 0.01), // Dynamic spacing
                        Text(
                          'Date of Birth: ${user['date_of_birth'] ?? 'N/A'}',
                          style: TextStyle(fontSize: screenHeight * 0.02),
                        ),
                        SizedBox(height: screenHeight * 0.01), // Dynamic spacing
                        Text(
                          'Gender: ${user['gender'] == 1 ? 'Male' : 'Female'}',
                          style: TextStyle(fontSize: screenHeight * 0.02),
                        ),
                        SizedBox(height: screenHeight * 0.03), // Dynamic spacing
                        ElevatedButton(
                          onPressed: () async {
                            final updated = await Navigator.pushNamed(
                              context,
                              '/edit_profile',
                              arguments: user, // Pass user data as arguments
                            );
                            if (updated == true) {
                              _loadUserData(); // Reload user data if it was updated
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.1,
                            ),
                          ),
                          child: Text(
                            'Edit Profile Information',
                            style: TextStyle(fontSize: screenHeight * 0.02),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02), // Dynamic spacing
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/change_password');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.1,
                            ),
                          ),
                          child: Text(
                            'Change Password',
                            style: TextStyle(fontSize: screenHeight * 0.02),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02), // Dynamic spacing
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/manage_account');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.1,
                            ),
                          ),
                          child: Text(
                            'Manage Account',
                            style: TextStyle(fontSize: screenHeight * 0.02),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 3, // Index for Account
      ),
    );
  }
}