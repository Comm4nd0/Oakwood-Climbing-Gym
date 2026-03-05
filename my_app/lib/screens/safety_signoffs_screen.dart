import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class SafetySignoffsScreen extends StatefulWidget {
  const SafetySignoffsScreen({super.key});

  @override
  State<SafetySignoffsScreen> createState() => _SafetySignoffsScreenState();
}

class _SafetySignoffsScreenState extends State<SafetySignoffsScreen> {
  List<Map<String, dynamic>> _signoffs = [];
  bool _isLoading = true;
  String? _error;

  // All possible sign-off types
  static const _allTypes = {
    'bouldering': 'Bouldering Health & Safety',
    'auto_belay': 'Auto Belay Induction',
    'top_rope': 'Top Rope Competency',
    'lead': 'Lead Climbing Competency',
  };

  static const _typeIcons = {
    'bouldering': Icons.terrain,
    'auto_belay': Icons.height,
    'top_rope': Icons.swap_vert,
    'lead': Icons.trending_up,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final signoffs = await api.getSafetySignoffs();
      setState(() {
        _signoffs = signoffs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load safety sign-offs.';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Sign-offs')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final completedTypes = _signoffs
        .where((s) => s['is_active'] == true)
        .map((s) => s['sign_off_type'] as String)
        .toSet();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Your climbing competency records. Speak to a staff member to get signed off for new activities.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        ..._allTypes.entries.map((entry) {
          final type = entry.key;
          final label = entry.value;
          final completed = completedTypes.contains(type);
          final signoff = _signoffs.firstWhere(
            (s) => s['sign_off_type'] == type && s['is_active'] == true,
            orElse: () => {},
          );

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: completed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                child: Icon(
                  _typeIcons[type] ?? Icons.verified_user,
                  color: completed ? Colors.green : Colors.grey,
                ),
              ),
              title: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: completed
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Signed off: ${_formatDate(signoff['date_signed']?.toString())}'),
                        if (signoff['signed_off_by_name'] != null &&
                            signoff['signed_off_by_name'].toString().trim().isNotEmpty)
                          Text('By: ${signoff['signed_off_by_name']}'),
                        if (signoff['notes'] != null &&
                            signoff['notes'].toString().trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              signoff['notes'],
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                      ],
                    )
                  : const Text('Not yet completed'),
              trailing: Icon(
                completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completed ? Colors.green : Colors.grey.shade400,
              ),
              isThreeLine: completed,
            ),
          );
        }),
      ],
    );
  }
}
