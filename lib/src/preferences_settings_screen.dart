import 'package:flutter/material.dart';

class PreferencesSettingsScreen extends StatefulWidget {
  const PreferencesSettingsScreen({super.key});

  @override
  State<PreferencesSettingsScreen> createState() => _PreferencesSettingsScreenState();
}

class _PreferencesSettingsScreenState extends State<PreferencesSettingsScreen> {
  bool hasEquipment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences Settings')),
      body: ListTile(
        title: const Text('Equipment'),
        subtitle: Text(hasEquipment ? 'Enabled' : 'Disabled'),
        trailing: Switch(
          value: hasEquipment,
          onChanged: (value) {
            setState(() {
              hasEquipment = value;
            });
          },
        ),
      ),
    );
  }
}