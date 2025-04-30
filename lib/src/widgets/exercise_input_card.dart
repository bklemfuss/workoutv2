import 'package:flutter/material.dart';
import '../services/database_helper.dart'; // For accessing the database helper
import '../widgets/exercise_details_dialog.dart';

class ExerciseInputCard extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(Map<String, dynamic>) onChanged;

  const ExerciseInputCard({super.key, required this.exercise, required this.onChanged});

  @override
  State<ExerciseInputCard> createState() => _ExerciseInputCardState();
}

class _ExerciseInputCardState extends State<ExerciseInputCard> {
  late List<Map<String, dynamic>> sets; // Store multiple sets for the exercise

  @override
  void initState() {
    super.initState();
    // Ensure the sets list is mutable by creating a new list
    sets = List<Map<String, dynamic>>.from(widget.exercise['rows'] ?? [
      {
        'reps': widget.exercise['reps'] ?? 0,
        'weight': widget.exercise['weight'] ?? 0.0,
      }
    ]);
    debugPrint('Initialized sets: $sets');
  }

  void _addSet() {
    setState(() {
      sets = List<Map<String, dynamic>>.from(sets); // Ensure sets is mutable
      sets.add({'reps': 0, 'weight': 0.0}); // Add a new set with default values
    });
    debugPrint('Set added: $sets');
    widget.onChanged({
      'exercise_id': widget.exercise['exercise_id'],
      'rows': sets, // Send all rows (sets) for this exercise
    });
  }

  void _onSetChanged(int index, String field, dynamic value) {
    setState(() {
      sets = List<Map<String, dynamic>>.from(sets); // Ensure sets is mutable
      sets[index][field] = value; // Update the specific set's field
    });
    debugPrint('Set changed: $sets');
    widget.onChanged({
      'exercise_id': widget.exercise['exercise_id'],
      'rows': sets, // Send all rows (sets) for this exercise
    });
  }

  void _showNotesDialog(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    final TextEditingController notesController = TextEditingController(
      text: widget.exercise['exercise_notes'] ?? '', // Pre-fill with existing notes
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
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedNotes = notesController.text;
                // Use the helper function to update the notes
                await dbHelper.updateExerciseNotes(
                  widget.exercise['exercise_id'],
                  updatedNotes,
                );
                // Update the local state
                setState(() {
                  widget.exercise['exercise_notes'] = updatedNotes;
                });
                Navigator.of(context).pop(); // Close dialog after saving
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
    final theme = Theme.of(context); // Access the current theme
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.cardColor], // Gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16), // Match the card's border radius
      ),
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.005,
      ),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
        color: Colors.transparent, // Make the card's color transparent
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
              // Row with Exercise Name and Percentage Field
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
                    width: screenWidth * 0.1, // Half the width of input boxes
                    height: screenHeight * 0.04, // Same height/width proportions as input boxes
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor, // Same color as inputFieldBackground
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '0%', // Placeholder text
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              // Row with Notes Icon and Input Fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.note_add, color: theme.primaryColor),
                    onPressed: () {
                      _showNotesDialog(context); // Show notes dialog
                    },
                  ),
                  SizedBox(width: screenWidth * 0.02), // Space between icon and input fields
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, // Push inputs to the right
                      children: [
                        _buildInputField(
                          label: 'Reps',
                          controller: TextEditingController(
                              text: sets[0]['reps'].toString()),
                          onChanged: (value) => _onSetChanged(
                              0, 'reps', int.tryParse(value) ?? 0),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildInputField(
                          label: 'Weight',
                          controller: TextEditingController(
                              text: sets[0]['weight'].toString()),
                          onChanged: (value) => _onSetChanged(
                              0, 'weight', double.tryParse(value) ?? 0.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  for (int i = 1; i < sets.length; i++) // Render each set
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // Align to the right
                      children: [
                        _buildInputField(
                          label: 'Reps',
                          controller: TextEditingController(
                              text: sets[i]['reps'].toString()),
                          onChanged: (value) => _onSetChanged(
                              i, 'reps', int.tryParse(value) ?? 0),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildInputField(
                          label: 'Weight',
                          controller: TextEditingController(
                              text: sets[i]['weight'].toString()),
                          onChanged: (value) => _onSetChanged(
                              i, 'weight', double.tryParse(value) ?? 0.0),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: _addSet,
                  child: const Icon(Icons.add), // "+" button
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
          style: theme.textTheme.bodyLarge, // Slightly larger text for labels
        ),
        SizedBox(
          width: screenWidth * 0.2, // Slightly wider input box
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              fillColor: theme.inputDecorationTheme.fillColor, // Light grey background
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), // Adjust padding
            ),
            style: theme.textTheme.bodyLarge, // Slightly larger text for input
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