import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController(text: '0.00');

  String _classType = 'boulder_taster';
  String _difficulty = 'all_levels';
  String _ageGroup = 'adult';
  bool _includesShoeHire = false;
  bool _isLoading = false;

  static const _classTypes = {
    'boulder_taster': 'Boulder Taster',
    'auto_belay_induction': 'Auto Belay Induction',
    'beginner_rope': "Beginner's Rope Course",
    'lead_climbing': 'Lead Climbing',
    'coaching': 'Coaching Session',
    'private_session': 'Private Session',
    'adult_social': 'Adult Social',
    'youth_session': 'Youth Session',
    'nicas': 'NICAS Course',
    'nibas': 'NIBAS Course',
    'yoga': 'Yoga for Climbers',
    'birthday_party': 'Birthday Party',
  };

  static const _difficulties = {
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
    'all_levels': 'All Levels',
  };

  static const _ageGroups = {
    'adult': 'Adult (18+)',
    'youth_5_7': 'Youth (5-7)',
    'youth_7_12': 'Youth (7-12)',
    'youth_13_17': 'Youth (13-17)',
    'all_ages': 'All Ages (4+)',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();
      await api.createClass(
        name: _nameController.text.trim(),
        classType: _classType,
        description: _descriptionController.text.trim(),
        difficulty: _difficulty,
        ageGroup: _ageGroup,
        maxParticipants: int.parse(_maxParticipantsController.text.trim()),
        durationMinutes: int.parse(_durationController.text.trim()),
        price: double.parse(_priceController.text.trim()),
        includesShoeHire: _includesShoeHire,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // true = created
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create class. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Class')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a class name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Class Type
              DropdownButtonFormField<String>(
                value: _classType,
                decoration: const InputDecoration(
                  labelText: 'Class Type',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _classTypes.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _classType = value);
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Difficulty & Age Group row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: _difficulties.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _difficulty = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _ageGroup,
                      decoration: const InputDecoration(
                        labelText: 'Age Group',
                        border: OutlineInputBorder(),
                      ),
                      items: _ageGroups.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _ageGroup = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Max Participants & Duration row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxParticipantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max Participants',
                        prefixIcon: Icon(Icons.group),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final n = int.tryParse(value.trim());
                        if (n == null || n < 1) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                        prefixIcon: Icon(Icons.timer),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final n = int.tryParse(value.trim());
                        if (n == null || n < 1) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final n = double.tryParse(value.trim());
                  if (n == null || n < 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Includes Shoe Hire
              SwitchListTile(
                title: const Text('Includes Shoe Hire'),
                subtitle: const Text('Climbing shoes provided with this class'),
                value: _includesShoeHire,
                onChanged: (value) =>
                    setState(() => _includesShoeHire = value),
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(_isLoading ? 'Creating...' : 'Create Class'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
