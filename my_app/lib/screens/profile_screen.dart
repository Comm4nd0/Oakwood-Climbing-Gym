import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'staff/staff_hub_screen.dart';
import 'membership_screen.dart';
import 'my_bookings_screen.dart';
import 'safety_signoffs_screen.dart';
import 'waiver_screen.dart';
import 'gym_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _memberships = [];
  bool _loading = true;
  bool _uploadingImage = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = context.read<ApiService>();
      final results = await Future.wait([
        api.getProfile(),
        api.getMemberships(),
      ]);
      setState(() {
        _profile = results[0] as Map<String, dynamic>;
        _memberships = results[1] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image == null) return;

      if (!mounted) return;
      setState(() => _uploadingImage = true);
      final api = context.read<ApiService>();
      final updatedProfile = await api.uploadProfileImage(image.path);
      setState(() {
        _profile = updatedProfile;
        _uploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated!')),
        );
      }
    } catch (e) {
      setState(() => _uploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update image: $e')),
        );
      }
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
    return full.isNotEmpty ? full : user['email'] ?? 'Climber';
  }

  String get _roleDisplay {
    if (_profile == null) return '';
    return _profile!['role'] ?? 'member';
  }

  String? get _profileImageUrl {
    if (_profile == null) return null;
    final img = _profile!['profile_image'];
    if (img == null || img.toString().isEmpty) return null;
    final url = img.toString();
    if (url.startsWith('http')) return url;
    return '${ApiConstants.baseUrl}$url';
  }

  List<_TagInfo> get _tags {
    final tags = <_TagInfo>[];

    // Role tag
    final role = _roleDisplay;
    if (role == 'admin') {
      tags.add(_TagInfo('Admin', Colors.red, Icons.shield));
    } else if (role == 'duty_manager') {
      tags.add(_TagInfo('Duty Manager', Colors.deepPurple, Icons.supervisor_account));
    } else if (role == 'instructor') {
      tags.add(_TagInfo('Instructor', Colors.orange, Icons.school));
    } else if (role == 'staff') {
      tags.add(_TagInfo('Staff', Colors.blue, Icons.badge));
    }

    // Membership tag
    final activeMembership = _memberships.where((m) {
      final s = m['status']?.toString() ?? '';
      return s == 'active' || s == 'frozen';
    }).toList();

    if (activeMembership.isNotEmpty) {
      final mem = activeMembership.first;
      final planName = mem['plan_name']?.toString() ?? 'Member';
      final memStatus = mem['status']?.toString() ?? '';
      if (memStatus == 'frozen') {
        tags.add(_TagInfo('$planName (Frozen)', Colors.blueGrey, Icons.ac_unit));
      } else {
        tags.add(_TagInfo(planName, Colors.green, Icons.card_membership));
      }
    } else if (role == 'member') {
      tags.add(_TagInfo('No Active Plan', Colors.grey, Icons.card_membership));
    }

    // Student / NHS / Military discount tags
    if (_profile?['is_student'] == true) {
      tags.add(_TagInfo('Student', Colors.teal, Icons.school_outlined));
    }
    if (_profile?['is_nhs'] == true) {
      tags.add(_TagInfo('NHS', Colors.indigo, Icons.local_hospital));
    }
    if (_profile?['is_military'] == true) {
      tags.add(_TagInfo('Military', Colors.brown, Icons.military_tech));
    }

    return tags;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ---- Profile image with edit button ----
                    GestureDetector(
                      onTap: _uploadingImage ? null : _pickAndUploadImage,
                      child: Stack(
                        children: [
                          _buildAvatar(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _uploadingImage ? Icons.hourglass_top : Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      _displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),

                    // ---- Tags ----
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: _tags
                          .map((t) => Chip(
                                avatar: Icon(t.icon, size: 16, color: Colors.white),
                                label: Text(
                                  t.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: t.color,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MembershipScreen()),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.event_note,
                      title: 'My Bookings',
                      subtitle: 'View upcoming class bookings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.verified_user,
                      title: 'Safety Sign-offs',
                      subtitle: 'Your climbing competency records',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SafetySignoffsScreen()),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.description,
                      title: 'Waiver',
                      subtitle: 'View or update your waiver',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WaiverScreen()),
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'Gym Info',
                      subtitle: 'Hours, location, and contact',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GymInfoScreen()),
                      ),
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
            ),
    );
  }

  Widget _buildAvatar() {
    final url = _profileImageUrl;
    if (_uploadingImage) {
      return const CircleAvatar(
        radius: 50,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 50,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircleAvatar(
          radius: 50,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => const CircleAvatar(
          radius: 50,
          child: Icon(Icons.person, size: 50),
        ),
      );
    }
    return const CircleAvatar(
      radius: 50,
      child: Icon(Icons.person, size: 50),
    );
  }
}

class _TagInfo {
  final String label;
  final Color color;
  final IconData icon;
  _TagInfo(this.label, this.color, this.icon);
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
