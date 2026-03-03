import 'package:flutter/material.dart';
import 'routes_screen.dart';
import 'classes_screen.dart';
import 'logbook_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardTab(),
    RoutesScreen(),
    ClassesScreen(),
    LogbookScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Routes'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Logbook'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oakwood Climbing Gym'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.terrain,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to climb today?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Sends',
                    value: '--',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.flash_on,
                    label: 'Flashes',
                    value: '--',
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up,
                    label: 'Total Logs',
                    value: '--',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_circle,
                    label: 'Log a Send',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.event_available,
                    label: 'Book a Class',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Gym Hours
            Text(
              'Gym Hours',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _HoursRow(day: 'Mon - Thu', hours: '6:00 AM - 10:00 PM'),
                    _HoursRow(day: 'Friday', hours: '6:00 AM - 9:00 PM'),
                    _HoursRow(day: 'Saturday', hours: '8:00 AM - 8:00 PM'),
                    _HoursRow(day: 'Sunday', hours: '8:00 AM - 6:00 PM'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;

  const _HoursRow({required this.day, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(hours),
        ],
      ),
    );
  }
}
