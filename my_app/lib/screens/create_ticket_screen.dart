import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'general';
  String _priority = 'medium';
  bool _submitting = false;

  static const _categories = <String, String>{
    'general': 'General Enquiry',
    'billing': 'Billing & Payments',
    'classes': 'Classes & Bookings',
    'facilities': 'Facilities & Equipment',
    'feedback': 'Feedback & Suggestions',
    'other': 'Other',
  };

  static const _priorities = <String, String>{
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
  };

  static const _priorityColors = <String, Color>{
    'low': Colors.green,
    'medium': Colors.orange,
    'high': Colors.red,
  };

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final api = context.read<ApiService>();
      await api.createSupportTicket(
        subject: _subjectController.text.trim(),
        category: _category,
        priority: _priority,
        message: _messageController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket submitted successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit ticket: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Support Ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Brief summary of your issue',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter a subject';
                  if (v.trim().length < 5) return 'Subject must be at least 5 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 20),

              // Priority choice chips
              Text(
                'Priority',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _priorities.entries.map((e) {
                  final selected = _priority == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(e.value),
                      selected: selected,
                      selectedColor: _priorityColors[e.key]!.withAlpha(50),
                      side: BorderSide(
                        color: selected
                            ? _priorityColors[e.key]!
                            : Colors.grey.shade300,
                      ),
                      labelStyle: TextStyle(
                        color: selected ? _priorityColors[e.key] : null,
                        fontWeight: selected ? FontWeight.bold : null,
                      ),
                      onSelected: (_) => setState(() => _priority = e.key),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Message
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Describe your issue or question in detail...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter a message';
                  if (v.trim().length < 10) return 'Message must be at least 10 characters';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_submitting ? 'Submitting...' : 'Submit Ticket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
