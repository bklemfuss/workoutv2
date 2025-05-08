import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class CreateExerciseDialog extends StatefulWidget {
  final VoidCallback? onExerciseCreated;

  const CreateExerciseDialog({Key? key, this.onExerciseCreated}) : super(key: key);

  @override
  State<CreateExerciseDialog> createState() => _CreateExerciseDialogState();
}

class _CreateExerciseDialogState extends State<CreateExerciseDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedMuscleGroup = 'All';
  bool _requiresEquipment = true;
  bool _isSaving = false;

  final List<String> _muscleGroups = ['All', 'Chest', 'Back', 'Legs', 'Arms', 'Core'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Create New Exercise',
        style: theme.textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _nameController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'Enter exercise name',
                  labelStyle: theme.textTheme.bodyMedium,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: theme.inputDecorationTheme.border,
                  contentPadding: theme.inputDecorationTheme.contentPadding,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _descriptionController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter exercise description',
                  labelStyle: theme.textTheme.bodyMedium,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: theme.inputDecorationTheme.border,
                  contentPadding: theme.inputDecorationTheme.contentPadding,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Muscle Group',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedMuscleGroup,
                    items: _muscleGroups
                        .map((group) => DropdownMenuItem(
                              value: group,
                              child: Text(group, style: theme.textTheme.bodyLarge),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMuscleGroup = value;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                    ),
                    style: theme.textTheme.bodyLarge,
                    dropdownColor: theme.dialogTheme.backgroundColor ?? theme.colorScheme.background,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _requiresEquipment,
                  onChanged: (value) {
                    setState(() {
                      _requiresEquipment = value ?? false;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                Text(
                  'Requires Equipment',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  final name = _nameController.text.trim();
                  final description = _descriptionController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Exercise name cannot be empty!'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                    return;
                  }
                  setState(() => _isSaving = true);
                  try {
                    await DatabaseHelper().addCustomExercise(
                      name: name,
                      description: description,
                      muscleGroup: _selectedMuscleGroup,
                      requiresEquipment: _requiresEquipment,
                    );
                    if (widget.onExerciseCreated != null) {
                      widget.onExerciseCreated!();
                    }
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Custom exercise created successfully!'),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create exercise: $e'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
          child: Text('Save', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
        ),
      ],
    );
  }
}
