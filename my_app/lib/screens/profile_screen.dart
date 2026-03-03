import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'staff/staff_hub_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final api = context.read<ApiService>();
      final profile = await api.getProfile();
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  bool get _isStaff {
    if (_profile == null) return false;
    return _profile!['is_staff_role'] == true;
  }

  String get _displayName {
    if (_profile == null) return 'Climber';
    final user = _profile!['user'] as Map<String, dynamic>?;
    if (user == null) return 'Climber';
    final full = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    return full.isNotEmpty ? full : user['username'] ?? 'Climber';
  }

  String get _roleDisplay {
    if (_profile == null) return '';
    return _profile!['role'] ?? 'member';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              _displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_roleDisplay.isNotEmpty)
              Text(
                _roleDisplay.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: _isStaff ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 32),

            // Staff Hub (only for staff roles)
            if (_isStaff)
              _ProfileMenuItem(
                icon: Icons.admin_panel_settings,
                title: 'Staff Hub',
                subtitle: 'Check-in, shifts, capacity management',
                iconColor: Colors.deepPurple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffHubScreen()),
                ),
              ),

            _ProfileMenuItem(
              icon: Icons.card_membership,
              title: 'Membership',
              subtitle: 'View your membership details',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.event_note,
              title: 'My Bookings',
              subtitle: 'View upcoming class bookings',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.verified_user,
              title: 'Safety Sign-offs',
              subtitle: 'Your climbing competency records',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.description,
              title: 'Waiver',
              subtitle: 'View or update your waiver',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'Gym Info',
              subtitle: 'Hours, location, and contact',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AuthService>().logout();
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
