import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class GymInfoScreen extends StatefulWidget {
  const GymInfoScreen({super.key});

  @override
  State<GymInfoScreen> createState() => _GymInfoScreenState();
}

class _GymInfoScreenState extends State<GymInfoScreen> {
  Map<String, dynamic>? _info;
  bool _isLoading = true;
  String? _error;

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
      final info = await api.getGymInfo();
      setState(() {
        _info = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load gym info.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Info')),
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

    if (_info == null) {
      return const Center(child: Text('No gym info available.'));
    }

    final info = _info!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name & description
          Text(
            info['name'] ?? 'Climbing Gym',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (info['description'] != null)
            Text(
              info['description'],
              style: Theme.of(context).textTheme.bodyLarge,
            ),

          const SizedBox(height: 24),

          // Contact details
          _SectionTitle(title: 'Contact'),
          const SizedBox(height: 8),
          if (info['address'] != null)
            _ContactRow(icon: Icons.location_on, value: info['address']),
          if (info['phone'] != null)
            _ContactRow(icon: Icons.phone, value: info['phone']),
          if (info['email'] != null)
            _ContactRow(icon: Icons.email, value: info['email']),
          if (info['website'] != null)
            _ContactRow(icon: Icons.language, value: info['website']),

          const SizedBox(height: 24),

          // Opening hours
          _SectionTitle(title: 'Opening Hours'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _HoursRow(day: 'Monday', hours: info['monday_hours']),
                  _HoursRow(day: 'Tuesday', hours: info['tuesday_hours']),
                  _HoursRow(day: 'Wednesday', hours: info['wednesday_hours']),
                  _HoursRow(day: 'Thursday', hours: info['thursday_hours']),
                  _HoursRow(day: 'Friday', hours: info['friday_hours']),
                  _HoursRow(day: 'Saturday', hours: info['saturday_hours']),
                  _HoursRow(day: 'Sunday', hours: info['sunday_hours']),
                ],
              ),
            ),
          ),

          if (info['peak_info'] != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.amber.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        info['peak_info'],
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String? hours;
  const _HoursRow({required this.day, this.hours});

  @override
  Widget build(BuildContext context) {
    // Highlight today
    final today = DateTime.now().weekday; // 1=Mon ... 7=Sun
    final dayMap = {
      'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4,
      'Friday': 5, 'Saturday': 6, 'Sunday': 7,
    };
    final isToday = dayMap[day] == today;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hours ?? 'Closed',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Today',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
