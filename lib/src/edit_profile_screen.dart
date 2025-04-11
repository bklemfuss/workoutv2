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
  late TextEditingController dobController;
  late int gender; // 1 for Male, 0 for Female
  late int selectedHeight; // Height in inches

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the user's data
    nameController = TextEditingController(text: widget.user['name']);
    dobController = TextEditingController(text: widget.user['date_of_birth']);
    gender = widget.user['gender'] ?? 1; // Default to Male if null

    // Ensure selectedHeight is within the valid range (48 to 99 inches)
    selectedHeight = widget.user['height'] ?? 60; // Default to 60 inches if null
    if (selectedHeight < 48 || selectedHeight > 99) {
      selectedHeight = 60; // Reset to default if out of range
    }
  }

  Future<void> _saveProfile() async {
    // Update the user data in the database
    await DatabaseHelper().updateUser({
      'user_id': 1, // Assuming user_id is always 1
      'name': nameController.text,
      'height': selectedHeight,
      'date_of_birth': dobController.text,
      'gender': gender,
    });

    // Navigate back to the AccountScreen
    if (mounted) {
      Navigator.pop(context, true); // Pass true to indicate data was updated
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dobController.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text = pickedDate.toIso8601String().split('T').first; // Format as YYYY-MM-DD
      });
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
            Row(
              children: [
                const Text('Height:', style: TextStyle(fontSize: 16)),
                SizedBox(width: screenWidth * 0.05),
                DropdownButton<int>(
                  value: selectedHeight,
                  items: List.generate(
                    52, // 48 to 99 inches
                    (index) => DropdownMenuItem(
                      value: 48 + index,
                      child: Text('${48 + index} inches'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedHeight = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                const Text('Date of Birth:', style: TextStyle(fontSize: 16)),
                SizedBox(width: screenWidth * 0.05),
                Expanded(
                  child: TextField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: const InputDecoration(
                      hintText: 'Select Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                ),
              ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Return without saving
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.1,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                ),
                ElevatedButton(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}