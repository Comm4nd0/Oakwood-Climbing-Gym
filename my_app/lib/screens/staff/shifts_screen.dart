import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/staff_shift.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  List<StaffShift> _shifts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final shifts = await api.getMyShifts();
      setState(() {
        _shifts = shifts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load shifts';
        _isLoading = false;
      });
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'duty_manager':
        return Colors.red;
      case 'instructor':
        return Colors.blue;
      case 'reception':
        return Colors.green;
      case 'route_setter':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Shifts')),
      body: RefreshIndicator(
        onRefresh: _loadShifts,
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
    if (_shifts.isEmpty) {
      return const Center(child: Text('No upcoming shifts.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _shifts.length,
      itemBuilder: (context, index) {
        final shift = _shifts[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      shift.date,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _roleColor(shift.shiftRole).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        shift.shiftRoleDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _roleColor(shift.shiftRole),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${shift.startTime} - ${shift.endTime}'),
                    const SizedBox(width: 16),
                    Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(shift.shiftTypeDisplay),
                    if (shift.isKeyHolder) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.vpn_key, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Key Holder',
                        style: TextStyle(color: Colors.amber.shade700),
                      ),
                    ],
                  ],
                ),
                if (shift.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    shift.notes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
