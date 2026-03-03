import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/check_in.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  List<CheckInRecord> _activeCheckIns = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final checkIns = await api.getActiveCheckIns();
      setState(() {
        _activeCheckIns = checkIns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load check-ins';
        _isLoading = false;
      });
    }
  }

  Future<void> _showCheckInDialog() async {
    final nameController = TextEditingController();
    String entryType = 'day_pass';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Check-in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Visitor Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: entryType,
                decoration: const InputDecoration(
                  labelText: 'Entry Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'membership', child: Text('Membership')),
                  DropdownMenuItem(value: 'day_pass', child: Text('Day Pass')),
                  DropdownMenuItem(value: 'punch_card', child: Text('Punch Card')),
                  DropdownMenuItem(value: 'class_booking', child: Text('Class Booking')),
                  DropdownMenuItem(value: 'party', child: Text('Birthday Party')),
                  DropdownMenuItem(value: 'spectator', child: Text('Spectator')),
                ],
                onChanged: (val) {
                  setDialogState(() => entryType = val!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, {
                  'name': nameController.text,
                  'entry_type': entryType,
                });
              },
              child: const Text('Check In'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['name']!.isNotEmpty) {
      try {
        final api = context.read<ApiService>();
        await api.checkInMember(
          visitorName: result['name'],
          entryType: result['entry_type']!,
        );
        _loadCheckIns();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to check in'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _checkOut(CheckInRecord record) async {
    try {
      final api = context.read<ApiService>();
      await api.checkOut(record.id);
      _loadCheckIns();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to check out'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in (${_activeCheckIns.length} in gym)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCheckInDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Check In'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCheckIns,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_activeCheckIns.isEmpty) {
      return const Center(child: Text('No one checked in yet today.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _activeCheckIns.length,
      itemBuilder: (context, index) {
        final record = _activeCheckIns[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(record.memberName),
            subtitle: Text(record.entryType.replaceAll('_', ' ').toUpperCase()),
            trailing: TextButton.icon(
              onPressed: () => _checkOut(record),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Out'),
            ),
          ),
        );
      },
    );
  }
}
