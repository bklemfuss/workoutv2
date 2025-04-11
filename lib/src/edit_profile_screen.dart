import 'package:flutter/material.dart';
import 'services/database_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController heightController;
  late TextEditingController dobController;
  late int gender; // 1 for Male, 0 for Female

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the user's data
    nameController = TextEditingController(text: widget.user['name']);
    heightController = TextEditingController(text: widget.user['height']?.toString());
    dobController = TextEditingController(text: widget.user['date_of_birth']);
    gender = widget.user['gender'] ?? 1; // Default to Male if null
  }

  Future<void> _saveProfile() async {
    // Update the user data in the database
    await DatabaseHelper().updateUser({
      'user_id': 1, // Assuming user_id is always 1
      'name': nameController.text,
      'height': int.tryParse(heightController.text) ?? widget.user['height'],
      'date_of_birth': dobController.text,
      'gender': gender,
    });

    // Navigate back to the AccountScreen
    if (mounted) {
      Navigator.pop(context, true); // Pass true to indicate data was updated
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                const Text('Gender:', style: TextStyle(fontSize: 16)),
                SizedBox(width: screenWidth * 0.05),
                Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    const Text('Male'),
                  ],
                ),
                Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                    const Text('Female'),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                    horizontal: screenWidth * 0.1,
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}