import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class PersonalRecordsGraph extends StatefulWidget {
  const PersonalRecordsGraph({super.key});

  @override
  State<PersonalRecordsGraph> createState() => _PersonalRecordsGraphState();
}

class _PersonalRecordsGraphState extends State<PersonalRecordsGraph> {
  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchPersonalRecords();
  }

  Future<List<Map<String, dynamic>>> _fetchPersonalRecords() async {
    final db = DatabaseHelper();
    final result = await db.database.then((db) => db.rawQuery('''
      SELECT 
        e.exercise_id,
        e.name AS exercise_name,
        mg.Name AS muscle_group,
        MAX(we.weight) AS max_weight,
        MAX(we.reps) AS max_reps,
        MAX(we.weight * we.reps) AS max_volume
      FROM WorkoutExercise we
      INNER JOIN Exercise e ON we.exercise_id = e.exercise_id
      LEFT JOIN MuscleGroup mg ON e.muscle_group_id = mg.muscle_group_id
      GROUP BY we.exercise_id
      ORDER BY mg.Name, e.name
    '''));
    return result.map((row) => {
      'exercise_id': row['exercise_id'],
      'exercise_name': row['exercise_name'],
      'muscle_group': row['muscle_group'] ?? 'Other',
      'max_weight': (row['max_weight'] as num?)?.toStringAsFixed(1) ?? '0',
      'max_reps': (row['max_reps'] as num?)?.toStringAsFixed(0) ?? '0',
      'max_volume': (row['max_volume'] as num?)?.toStringAsFixed(1) ?? '0',
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Records'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading records', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No personal records found.', style: theme.textTheme.bodyMedium));
          }

          // Group by muscle group
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final record in snapshot.data!) {
            final group = record['muscle_group'] ?? 'Other';
            grouped.putIfAbsent(group, () => []).add(record);
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: grouped.entries.map((entry) {
              final groupName = entry.key;
              final records = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      groupName,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      3: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          const SizedBox(),
                          Center(child: Icon(Icons.fitness_center, size: 18, color: theme.colorScheme.primary)), // Weight
                          Center(child: Icon(Icons.repeat, size: 18, color: theme.colorScheme.secondary)), // Reps
                          Center(child: Icon(Icons.bolt, size: 18, color: theme.colorScheme.tertiary)), // Volume
                        ],
                      ),
                      ...records.map((rec) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              rec['exercise_name'] ?? '',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Center(child: Text('${rec['max_weight']}', style: theme.textTheme.bodyMedium)),
                          Center(child: Text('${rec['max_reps']}', style: theme.textTheme.bodyMedium)),
                          Center(child: Text('${rec['max_volume']}', style: theme.textTheme.bodyMedium)),
                        ],
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
