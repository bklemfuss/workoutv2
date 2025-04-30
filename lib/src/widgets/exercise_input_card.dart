import 'package:flutter/material.dart';
import '../services/database_helper.dart'; // For accessing the database helper
import '../widgets/exercise_details_dialog.dart';

class ExerciseInputCard extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(int exerciseId, List<Map<String, dynamic>> sets) onSetsChanged; // Changed callback

  const ExerciseInputCard({super.key, required this.exercise, required this.onSetsChanged});

  @override
  State<ExerciseInputCard> createState() => _ExerciseInputCardState();
}

class _ExerciseInputCardState extends State<ExerciseInputCard> {
  late List<Map<String, dynamic>> sets;

  @override
  void initState() {
    super.initState();
    sets = List<Map<String, dynamic>>.from(widget.exercise['sets'] ?? [
      {'reps': 0, 'weight': 0.0},
    ]);
  }

  void _addSet() {
    setState(() {
      sets.add({'reps': 0, 'weight': 0.0});
      widget.onSetsChanged(widget.exercise['exercise_id'], sets); // Notify about changes
    });
  }

  void _onSetChanged(int index, String field, dynamic value) {
    setState(() {
      sets[index][field] = value;
      widget.onSetsChanged(widget.exercise['exercise_id'], sets); // Notify about changes
    });
  }

    void _handleNotesUpdate(String updatedNotes) {
    setState(() {
      widget.exercise['exercise_notes'] = updatedNotes;
    });
  }

  void _showNotesDialog(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    final TextEditingController notesController = TextEditingController(
      text: widget.exercise['exercise_notes'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.exercise['exercise_name'] ?? 'Exercise Notes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.exercise['exercise_notes'] != null &&
                  widget.exercise['exercise_notes'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Existing Notes: ${widget.exercise['exercise_notes']}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              TextField(
                controller: notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter notes about this exercise...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedNotes = notesController.text;
                await dbHelper.updateExerciseNotes(
                  widget.exercise['exercise_id'],
                  updatedNotes,
                );
                _handleNotesUpdate(updatedNotes); // Update state
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.005,
      ),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
            horizontal: screenWidth * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ExerciseDetailsDialog(exercise: widget.exercise),
                      );
                    },
                    child: Text(
                      widget.exercise['exercise_name'] ?? widget.exercise['name'] ?? 'Unknown Exercise',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.04,
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '0%',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.note_add, color: theme.primaryColor),
                    onPressed: () {
                      _showNotesDialog(context);
                    },
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildInputField(
                          label: 'Reps',
                          controller: TextEditingController(text: sets[0]['reps'].toString()),
                          onChanged: (value) => _onSetChanged(0, 'reps', int.tryParse(value) ?? 0),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildInputField(
                          label: 'Weight',
                          controller: TextEditingController(text: sets[0]['weight'].toString()),
                          onChanged: (value) => _onSetChanged(0, 'weight', double.tryParse(value) ?? 0.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  for (int i = 1; i < sets.length; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildInputField(
                          label: 'Reps',
                          controller: TextEditingController(text: sets[i]['reps'].toString()),
                          onChanged: (value) => _onSetChanged(i, 'reps', int.tryParse(value) ?? 0),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildInputField(
                          label: 'Weight',
                          controller: TextEditingController(text: sets[i]['weight'].toString()),
                          onChanged: (value) => _onSetChanged(i, 'weight', double.tryParse(value) ?? 0.0),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: _addSet,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(
          width: screenWidth * 0.2,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: theme.inputDecorationTheme.fillColor,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            ),
            style: theme.textTheme.bodyLarge,
            onChanged: (value) => onChanged(value),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
