import 'package:flutter/material.dart';

class GoalsSettingsScreen extends StatefulWidget {
  const GoalsSettingsScreen({super.key});

  @override
  State<GoalsSettingsScreen> createState() => _GoalsSettingsScreenState();
}

class _GoalsSettingsScreenState extends State<GoalsSettingsScreen> {
  int workoutsPerWeek = 3;
  double weightGoal = 70.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals Settings')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Number of Workouts/Week'),
            trailing: DropdownButton<int>(
              value: workoutsPerWeek,
              items: List.generate(7, (index) => index + 1)
                  .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  workoutsPerWeek = value!;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Weight Goal'),
            trailing: ElevatedButton(
              onPressed: () async {
                final result = await showDialog<double>(
                  context: context,
                  builder: (context) {
                    double tempWeight = weightGoal;
                    return AlertDialog(
                      title: const Text('Set Weight Goal'),
                      content: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          tempWeight = double.tryParse(value) ?? weightGoal;
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, tempWeight),
                          child: const Text('Set'),
                        ),
                      ],
                    );
                  },
                );
                if (result != null) {
                  setState(() {
                    weightGoal = result;
                  });
                }
              },
              child: Text('$weightGoal kg'),
            ),
          ),
        ],
      ),
    );
  }
}