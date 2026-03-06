import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gym_class.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'login_screen.dart';

class ClassDetailScreen extends StatelessWidget {
  final GymClass gymClass;

  const ClassDetailScreen({super.key, required this.gymClass});

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    return '${ApiConstants.baseUrl}/$imagePath';
  }

  void _showBookingSheet(BuildContext context) {
    if (gymClass.schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No scheduled sessions available for booking.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _BookingSheet(gymClass: gymClass),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _getDifficultyColor(gymClass.difficulty);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                gymClass.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: gymClass.image != null
                  ? Image.network(
                      _buildImageUrl(gymClass.image!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildPlaceholder(diffColor),
                    )
                  : _buildPlaceholder(diffColor),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        label: gymClass.difficultyDisplay,
                        color: diffColor,
                      ),
                      _Badge(
                        label: gymClass.classTypeDisplay,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _Badge(
                        label: gymClass.ageGroupDisplay,
                        color: Colors.teal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    gymClass.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // Details grid
                  Text(
                    'Details',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _DetailRow(
                    icon: Icons.person,
                    label: 'Instructor',
                    value: gymClass.instructor,
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: '${gymClass.durationMinutes} minutes',
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.group,
                    label: 'Max participants',
                    value: '${gymClass.maxParticipants}',
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value: gymClass.price == 0
                        ? 'Free'
                        : '\u00a3${gymClass.price.toStringAsFixed(2)}',
                  ),
                  if (gymClass.includesShoeHire) ...[
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.checkroom,
                      label: 'Shoe hire',
                      value: 'Included',
                    ),
                  ],

                  // Schedule section
                  if (gymClass.schedules.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Schedule',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...gymClass.schedules.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 10),
                            Text(
                              s.dayOfWeekDisplay,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              s.startTime,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Book button
                  const SizedBox(height: 32),
                  Builder(
                    builder: (context) {
                      final isAuthenticated =
                          context.watch<AuthService>().isAuthenticated;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isAuthenticated
                              ? () => _showBookingSheet(context)
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                          icon: Icon(isAuthenticated
                              ? Icons.event_available
                              : Icons.login),
                          label: Text(
                            isAuthenticated
                                ? 'Book a Session'
                                : 'Sign In to Book',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      color: color.withOpacity(0.15),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 80,
          color: color.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─── Booking bottom sheet ────────────────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  final GymClass gymClass;
  const _BookingSheet({required this.gymClass});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int? _selectedScheduleId;
  DateTime? _selectedDate;
  List<DateTime> _availableDates = [];
  bool _isSubmitting = false;

  /// Return the next [count] occurrences of [dayOfWeek] starting from tomorrow.
  /// dayOfWeek: 0=Monday ... 6=Sunday  (Django convention)
  List<DateTime> _upcomingDatesForDay(int dayOfWeek, {int count = 4}) {
    final dartDay = dayOfWeek + 1; // Dart: 1=Monday ... 7=Sunday
    final dates = <DateTime>[];
    var d = DateTime.now().add(const Duration(days: 1));
    while (dates.length < count) {
      if (d.weekday == dartDay) {
        dates.add(d);
      }
      d = d.add(const Duration(days: 1));
    }
    return dates;
  }

  void _onScheduleSelected(ClassSchedule schedule) {
    final dates = _upcomingDatesForDay(schedule.dayOfWeek);
    setState(() {
      _selectedScheduleId = schedule.id;
      _availableDates = dates;
      _selectedDate = dates.first;
    });
  }

  Future<void> _submitBooking() async {
    if (_selectedScheduleId == null || _selectedDate == null) return;

    setState(() => _isSubmitting = true);

    try {
      final api = context.read<ApiService>();
      await api.createBooking(
        classScheduleId: _selectedScheduleId!,
        date:
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booked ${widget.gymClass.name}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.gymClass.schedules.isNotEmpty) {
      _onScheduleSelected(widget.gymClass.schedules.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedules = widget.gymClass.schedules;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Book ${widget.gymClass.name}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Pick a session
          Text(
            'Select a session',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: schedules.map((s) {
              final selected = _selectedScheduleId == s.id;
              return ChoiceChip(
                label: Text('${s.dayOfWeekDisplay} ${s.startTime}'),
                selected: selected,
                onSelected: (_) => _onScheduleSelected(s),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Pick a date from upcoming occurrences
          Text(
            'Date',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableDates.map((date) {
              final selected = _selectedDate != null &&
                  date.year == _selectedDate!.year &&
                  date.month == _selectedDate!.month &&
                  date.day == _selectedDate!.day;
              final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final monthNames = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
              ];
              final label =
                  '${dayNames[date.weekday - 1]} ${date.day} ${monthNames[date.month - 1]}';
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) {
                  setState(() => _selectedDate = date);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Price reminder
          if (widget.gymClass.price > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Price: \u00a3${widget.gymClass.price.toStringAsFixed(2)}${widget.gymClass.includesShoeHire ? ' (shoe hire included)' : ''}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),

          const SizedBox(height: 24),

          // Confirm
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed:
                  _isSubmitting || _selectedScheduleId == null || _selectedDate == null
                      ? null
                      : _submitBooking,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label:
                  Text(_isSubmitting ? 'Booking...' : 'Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
