import 'package:flutter/material.dart';
import '../services/database_helper.dart'; // For accessing the database helper
import '../widgets/exercise_details_dialog.dart';

class ExerciseInputCard extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final int templateId; // Add templateId
  final Function(int exerciseId, List<Map<String, dynamic>> sets) onSetsChanged;

  const ExerciseInputCard({
    super.key,
    required this.exercise,
    required this.templateId, // Require templateId
    required this.onSetsChanged,
  });

  @override
  State<ExerciseInputCard> createState() => _ExerciseInputCardState();
}

class _ExerciseInputCardState extends State<ExerciseInputCard> {
  late List<Map<String, dynamic>> sets;
  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;

  // State for percentage calculation
  double _previousTotalVolume = 0.0;
  double? _percentageChange;
  Color _percentageColor = Colors.grey; // Default color

  @override
  void initState() {
    super.initState();
    // Explicitly handle type casting and filter invalid elements for initial sets
    final initialSetsRaw = widget.exercise['sets'];
    List<Map<String, dynamic>> processedSets = []; // Initialize as empty

    if (initialSetsRaw != null && initialSetsRaw is List) {
      // Iterate and safely process each element
      for (var setElement in initialSetsRaw) {
        // Check if the element is a non-null Map
        if (setElement != null && setElement is Map) {
          final setMap = Map<String, dynamic>.from(setElement);
          processedSets.add({
            'reps': setMap['reps'] ?? 0,
            'weight': setMap['weight'] ?? 0.0,
            'isChecked': setMap['isChecked'] ?? false,
          });
        }
        // else: Skip null or non-Map elements
      }
    }

    // Ensure there's at least one set if the list ended up empty
    if (processedSets.isEmpty) {
      processedSets = [
        {'reps': 0, 'weight': 0.0, 'isChecked': false}, // Default first set
      ];
    }

    sets = processedSets;

    // Initialize controllers based on initial sets
    _weightControllers = sets
        .map((set) => TextEditingController(text: set['weight'].toString()))
        .toList();
    _repsControllers = sets
        .map((set) => TextEditingController(text: set['reps'].toString()))
        .toList();

    // Fetch previous volume and calculate initial percentage
    _fetchPreviousVolumeAndCalculatePercentage();
  }

  // Fetch previous volume and calculate percentage
  Future<void> _fetchPreviousVolumeAndCalculatePercentage() async {
    final dbHelper = DatabaseHelper();
    _previousTotalVolume = await dbHelper.getLastWorkoutVolumeForExercise(
      widget.templateId,
      widget.exercise['exercise_id'],
    );
    _calculateAndSetPercentage(); // Calculate based on fetched data and initial sets
  }

  // Calculate current total volume and percentage change
  void _calculateAndSetPercentage() {
    double currentTotalVolume = 0.0;
    // Only include checked sets in the current volume calculation
    for (final set in sets) {
      if (set['isChecked'] == true) { // Check if the set is checked
        final weight = (set['weight'] as num?)?.toDouble() ?? 0.0;
        final reps = (set['reps'] as num?)?.toInt() ?? 0;
        currentTotalVolume += weight * reps;
      }
    }

    setState(() {
      if (_previousTotalVolume == 0.0) {
        if (currentTotalVolume > 0.0) {
          _percentageChange = 100.0; // Treat as 100% if first time with volume
          _percentageColor = Colors.green;
        } else {
          _percentageChange = null; // No change if both are 0 or no sets checked
          _percentageColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
        }
      } else {
        // Avoid division by zero if previous volume is zero but current is not
        if (currentTotalVolume == 0.0) {
           _percentageChange = 0.0; // Show 0% if current volume is zero
           _percentageColor = Colors.red; // Or grey, depending on preference
        } else {
          _percentageChange = (currentTotalVolume / _previousTotalVolume) * 100.0;
          if (_percentageChange! >= 100.0) {
            _percentageColor = Colors.green;
          } else if (_percentageChange! >= 70.0) {
            _percentageColor = Colors.orange;
          } else {
            _percentageColor = Colors.red;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      // Add new set with isChecked field
      final newSet = {'reps': 0, 'weight': 0.0, 'isChecked': false};
      sets.add(newSet);
      // Add corresponding controllers
      _weightControllers.add(TextEditingController(text: newSet['weight'].toString()));
      _repsControllers.add(TextEditingController(text: newSet['reps'].toString()));
      widget.onSetsChanged(widget.exercise['exercise_id'], sets); // Notify about changes
      _calculateAndSetPercentage(); // Recalculate percentage
    });
  }

  void _onSetChanged(int index, String field, dynamic value) {
    setState(() {
      sets[index][field] = value;
      widget.onSetsChanged(widget.exercise['exercise_id'], sets); // Notify about changes
      _calculateAndSetPercentage(); // Recalculate percentage
    });
  }

  // Handler for checkbox changes
  void _onSetChecked(int index, bool? isChecked) {
    setState(() {
      sets[index]['isChecked'] = isChecked ?? false;
      widget.onSetsChanged(widget.exercise['exercise_id'], sets); // Notify about changes
      // Recalculate percentage when a checkbox changes
      _calculateAndSetPercentage();
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
                // *** Add Validation ***
                const maxLength = 500; // Example maximum length
                if (updatedNotes.length > maxLength) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Notes cannot exceed $maxLength characters.'), backgroundColor: Colors.red),
                   );
                   return; // Prevent saving
                }
                // *** End Validation ***

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

    // Determine percentage text and handle null case
    final percentageText = _percentageChange != null
        ? '${_percentageChange!.toStringAsFixed(0)}%'
        : '--%'; // Show '--%' if no previous data or current volume is 0

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
                    width: screenWidth * 0.15,
                    height: screenHeight * 0.04,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface, // Use themed surface color
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _percentageColor, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      percentageText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _percentageColor, // Keep dynamic color for meaning
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              // First set row (index 0)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.note_add, color: theme.primaryColor),
                    onPressed: () {
                      _showNotesDialog(context);
                    },
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Swapped Weight and Reps
                        _buildInputField(
                          label: 'Weight',
                          // Pass the existing controller
                          controller: _weightControllers[0],
                          onChanged: (value) => _onSetChanged(0, 'weight', double.tryParse(value) ?? 0.0),
                          isChecked: sets[0]['isChecked'], // Pass checked state
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildInputField(
                          label: 'Reps',
                          // Pass the existing controller
                          controller: _repsControllers[0],
                          onChanged: (value) => _onSetChanged(0, 'reps', int.tryParse(value) ?? 0),
                          isChecked: sets[0]['isChecked'], // Pass checked state
                        ),
                        SizedBox(width: screenWidth * 0.01), // Add some space before checkbox
                        // Moved Checkbox here
                        Checkbox(
                          value: sets[0]['isChecked'],
                          onChanged: (bool? value) => _onSetChecked(0, value),
                          activeColor: theme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Subsequent set rows (index 1 onwards)
              Column(
                children: [
                  for (int i = 1; i < sets.length; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Swapped Weight and Reps
                        _buildInputField(
                          label: 'Weight',
                          // Pass the existing controller
                          controller: _weightControllers[i],
                          onChanged: (value) => _onSetChanged(i, 'weight', double.tryParse(value) ?? 0.0),
                          isChecked: sets[i]['isChecked'], // Pass checked state
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        _buildInputField(
                          label: 'Reps',
                          // Pass the existing controller
                          controller: _repsControllers[i],
                          onChanged: (value) => _onSetChanged(i, 'reps', int.tryParse(value) ?? 0),
                          isChecked: sets[i]['isChecked'], // Pass checked state
                        ),
                        SizedBox(width: screenWidth * 0.01), // Add some space before checkbox
                        // Moved Checkbox here
                        Checkbox(
                          value: sets[i]['isChecked'],
                          onChanged: (bool? value) => _onSetChecked(i, value),
                          activeColor: theme.primaryColor, // Use theme color
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: _addSet,
                  // Explicitly set the icon color for better contrast
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary, // Use onPrimary color
                  ),
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
    required TextEditingController controller, // Accept controller
    required ValueChanged<String> onChanged,
    required bool isChecked, // Added isChecked parameter
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // Determine background color based on isChecked state
    final fillColor = isChecked
        ? theme.primaryColor.withOpacity(0.2) // Greenish tint when checked
        : theme.inputDecorationTheme.fillColor; // Default fill color

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
            controller: controller, // Use the passed controller
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: fillColor, // Use determined fill color
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            ),
            style: theme.textTheme.bodyLarge,
            onTap: () {
              if (controller.text == '0') {
                controller.clear(); // Clear the default value when tapped
              }
            },
            onChanged: (value) => onChanged(value),
          ),
        ),
      ],
    );
  }
}
