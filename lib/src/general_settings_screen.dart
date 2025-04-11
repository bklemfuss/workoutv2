import 'package:flutter/material.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool isMetric = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Settings')),
      body: ListTile(
        title: const Text('Units'),
        subtitle: Text(isMetric ? 'Metric' : 'Imperial'),
        trailing: Switch(
          value: isMetric,
          onChanged: (value) {
            setState(() {
              isMetric = value;
            });
          },
        ),
      ),
    );
  }
}