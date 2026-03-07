import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/wall_section.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({super.key});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setterController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  String? _selectedColor;
  int? _selectedWallId;
  XFile? _pickedImage;
  String _dateSet = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isLoading = false;

  List<WallSection> _walls = [];
  bool _wallsLoading = true;

  // Difficulty colours ordered easy → hard with V-scale ranges
  static const _difficultyColors = [
    ('green', 'Green', 'VB – V1', Color(0xFF4CAF50)),
    ('yellow', 'Yellow', 'V1 – V2', Color(0xFFF9A825)),
    ('blue', 'Blue', 'V2 – V4', Color(0xFF2196F3)),
    ('red', 'Red', 'V4 – V6', Color(0xFFF44336)),
    ('white', 'White', 'V6 – V8', Color(0xFFE0E0E0)),
    ('black', 'Black', 'V8+', Color(0xFF424242)),
  ];

  @override
  void initState() {
    super.initState();
    _loadWalls();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setterController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadWalls() async {
    try {
      final api = context.read<ApiService>();
      final walls = await api.getWalls();
      setState(() {
        _walls = walls;
        _wallsLoading = false;
      });
    } catch (e) {
      setState(() => _wallsLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateSet = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a difficulty colour'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();
      await api.createRoute(
        name: _nameController.text.trim(),
        color: _selectedColor!,
        wallSection: _selectedWallId!,
        setter: _setterController.text.trim(),
        dateSet: _dateSet,
        description: _descriptionController.text.trim(),
        imagePath: _pickedImage?.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create route. Please try again.'),
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
      appBar: AppBar(title: const Text('Add Route')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Route Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  prefixIcon: Icon(Icons.route),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a route name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Difficulty Colour
              Text(
                'Difficulty',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildColorSelector(),
              const SizedBox(height: 20),

              // Wall Section
              if (_wallsLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<int>(
                  value: _selectedWallId,
                  decoration: const InputDecoration(
                    labelText: 'Wall Section',
                    prefixIcon: Icon(Icons.landscape),
                    border: OutlineInputBorder(),
                  ),
                  items: _walls
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(w.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedWallId = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Please select a wall section';
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // Photo
              Text(
                'Photo',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_pickedImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add a photo',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Setter
              TextFormField(
                controller: _setterController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Setter',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the setter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Set
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date Set',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      hintText: _dateSet,
                    ),
                    controller: TextEditingController(text: _dateSet),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
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
                  label: Text(_isLoading ? 'Creating...' : 'Create Route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _difficultyColors.map((entry) {
        final (key, label, gradeRange, color) = entry;
        final isSelected = _selectedColor == key;
        final isLight = key == 'white' || key == 'yellow';

        return GestureDetector(
          onTap: () => setState(() => _selectedColor = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Column(
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: isLight ? Colors.black87 : Colors.white,
                    size: 20,
                  )
                else
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: color,
                    child: key == 'white'
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          )
                        : null,
                  ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                    color: isSelected && !isLight
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                Text(
                  gradeRange,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected && !isLight
                        ? Colors.white70
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
