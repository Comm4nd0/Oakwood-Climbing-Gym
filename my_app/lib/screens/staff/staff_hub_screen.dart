import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/capacity.dart';
import 'checkin_screen.dart';
import 'shifts_screen.dart';
import '../support_screen.dart';
import '../add_route_screen.dart';

class StaffHubScreen extends StatefulWidget {
  const StaffHubScreen({super.key});

  @override
  State<StaffHubScreen> createState() => _StaffHubScreenState();
}

class _StaffHubScreenState extends State<StaffHubScreen> {
  Capacity? _capacity;
  bool _loadingCapacity = true;

  @override
  void initState() {
    super.initState();
    _loadCapacity();
  }

  Future<void> _loadCapacity() async {
    try {
      final api = context.read<ApiService>();
      final capacity = await api.getCapacity();
      setState(() {
        _capacity = capacity;
        _loadingCapacity = false;
      });
    } catch (e) {
      setState(() => _loadingCapacity = false);
    }
  }

  Color _capacityColor(int percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Hub')),
      body: RefreshIndicator(
        onRefresh: _loadCapacity,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Capacity Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Live Capacity',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          if (_capacity != null && _capacity!.isPeak)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PEAK',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_loadingCapacity)
                        const Center(child: CircularProgressIndicator())
                      else if (_capacity != null) ...[
                        Center(
                          child: Text(
                            '${_capacity!.currentCount}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _capacityColor(_capacity!.percentage),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'of ${_capacity!.isPeak ? _capacity!.peakCapacity : _capacity!.maxCapacity} max',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _capacity!.percentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: _capacityColor(_capacity!.percentage),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_capacity!.percentage}% full',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              _StaffActionTile(
                icon: Icons.login,
                title: 'Check-in / Check-out',
                subtitle: 'Manage member and visitor check-ins',
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckInScreen()),
                ),
              ),
              _StaffActionTile(
                icon: Icons.calendar_month,
                title: 'My Shifts',
                subtitle: 'View your upcoming shifts',
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShiftsScreen()),
                ),
              ),
              _StaffActionTile(
                icon: Icons.route,
                title: 'Set Routes',
                subtitle: 'Add new climbing routes with photos',
                color: Colors.indigo,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddRouteScreen()),
                ),
              ),
              _StaffActionTile(
                icon: Icons.event_note,
                title: 'Manage Bookings',
                subtitle: 'View and manage class bookings',
                color: Colors.green,
                onTap: () {},
              ),
              _StaffActionTile(
                icon: Icons.verified_user,
                title: 'Safety Sign-offs',
                subtitle: 'Process climbing competency sign-offs',
                color: Colors.orange,
                onTap: () {},
              ),
              _StaffActionTile(
                icon: Icons.card_membership,
                title: 'Member Lookup',
                subtitle: 'Search and manage member profiles',
                color: Colors.teal,
                onTap: () {},
              ),
              _StaffActionTile(
                icon: Icons.support_agent,
                title: 'Support Tickets',
                subtitle: 'View and respond to member tickets',
                color: Colors.deepOrange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupportScreen(isStaff: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _StaffActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
