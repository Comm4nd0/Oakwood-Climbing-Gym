import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/climbing_route.dart';
import '../models/route_log.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../utils/grade_converter.dart';

class RouteDetailScreen extends StatefulWidget {
  final ClimbingRoute route;

  const RouteDetailScreen({super.key, required this.route});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  List<RouteLog> _myLogs = [];
  List<RouteLog> _communityLogs = [];
  bool _logsLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final api = context.read<ApiService>();
      final results = await Future.wait([
        api.getRouteLogsForRoute(widget.route.id),
        api.getProfile(),
      ]);
      final allLogs = results[0] as List<RouteLog>;
      final profile = results[1] as Map<String, dynamic>;
      final userId = profile['user']['id'] as int;
      setState(() {
        _currentUserId = userId;
        _myLogs = allLogs.where((l) => l.climber == userId).toList();
        _communityLogs = allLogs.where((l) => l.climber != userId).toList();
        _logsLoading = false;
      });
    } catch (_) {
      setState(() => _logsLoading = false);
    }
  }

  Color _getRouteColor(String color) {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow.shade700;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'white':
        return Colors.grey.shade300;
      case 'black':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    return '${ApiConstants.baseUrl}/$imagePath';
  }

  void _showLogDialog() {
    String attemptType = 'send';
    final notesController = TextEditingController();
    int? rating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                    'Log Completion',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.route.name} (${GradeConverter.dualGradeDisplay(widget.route.grade, widget.route.gradeSystem)})',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Attempt type
                  Text(
                    'How did it go?',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        avatar: attemptType == 'flash'
                            ? const Icon(Icons.bolt, size: 18)
                            : null,
                        label: const Text('Flash'),
                        selected: attemptType == 'flash',
                        onSelected: (_) {
                          setSheetState(() => attemptType = 'flash');
                        },
                      ),
                      ChoiceChip(
                        avatar: attemptType == 'send'
                            ? const Icon(Icons.check_circle, size: 18)
                            : null,
                        label: const Text('Send'),
                        selected: attemptType == 'send',
                        onSelected: (_) {
                          setSheetState(() => attemptType = 'send');
                        },
                      ),
                      ChoiceChip(
                        avatar: attemptType == 'attempt'
                            ? const Icon(Icons.trending_up, size: 18)
                            : null,
                        label: const Text('Attempt'),
                        selected: attemptType == 'attempt',
                        onSelected: (_) {
                          setSheetState(() => attemptType = 'attempt');
                        },
                      ),
                      ChoiceChip(
                        avatar: attemptType == 'project'
                            ? const Icon(Icons.star, size: 18)
                            : null,
                        label: const Text('Project'),
                        selected: attemptType == 'project',
                        onSelected: (_) {
                          setSheetState(() => attemptType = 'project');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating
                  Text(
                    'Rating (optional)',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      return IconButton(
                        icon: Icon(
                          rating != null && starValue <= rating!
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setSheetState(() {
                            rating = rating == starValue ? null : starValue;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Beta, conditions, how it felt...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _submitLog(
                          attemptType,
                          rating,
                          notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Log It'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitLog(
      String attemptType, int? rating, String? notes) async {
    try {
      final api = context.read<ApiService>();
      await api.createRouteLog(
        routeId: widget.route.id,
        attemptType: attemptType,
        rating: rating,
        notes: notes,
      );
      if (mounted) {
        final label = attemptType == 'flash'
            ? 'Flashed'
            : attemptType == 'send'
                ? 'Sent'
                : attemptType == 'attempt'
                    ? 'Attempt logged for'
                    : 'Projected';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label ${widget.route.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadLogs();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to log. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  IconData _attemptIcon(String type) {
    switch (type) {
      case 'flash':
        return Icons.bolt;
      case 'send':
        return Icons.check_circle;
      case 'attempt':
        return Icons.trending_up;
      case 'project':
        return Icons.star;
      default:
        return Icons.check;
    }
  }

  Color _attemptColor(String type) {
    switch (type) {
      case 'flash':
        return Colors.amber;
      case 'send':
        return Colors.green;
      case 'attempt':
        return Colors.blue;
      case 'project':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLogCard(RouteLog log, {required bool showName}) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _attemptColor(log.attemptType).withOpacity(0.1),
          child: Icon(
            _attemptIcon(log.attemptType),
            color: _attemptColor(log.attemptType),
          ),
        ),
        title: Text(
          showName ? log.climberName : log.attemptTypeDisplay,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showName)
              Text(
                log.attemptTypeDisplay,
                style: TextStyle(color: _attemptColor(log.attemptType)),
              ),
            Text(_formatDate(log.loggedAt)),
            if (log.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  log.notes,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
        trailing: log.rating != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${log.rating}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final routeColor = _getRouteColor(route.color);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogDialog,
        icon: const Icon(Icons.add),
        label: const Text('Log Send'),
      ),
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                route.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: route.image != null
                  ? Image.network(
                      _buildImageUrl(route.image!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(routeColor),
                    )
                  : _buildPlaceholder(routeColor),
            ),
          ),

          // Route details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grade and colour row
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 40,
                        decoration: BoxDecoration(
                          color: routeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        route.colorDisplay,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              route.grade,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (GradeConverter.convertGrade(route.grade, route.gradeSystem) != null)
                              Text(
                                GradeConverter.convertGrade(route.grade, route.gradeSystem)!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info cards
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Wall',
                    value: route.wallSectionName,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Setter',
                    value: route.setter,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Date set',
                    value: route.dateSet,
                  ),

                  // Description
                  if (route.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      route.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],

                  // Your logs
                  const SizedBox(height: 28),
                  Text(
                    'Your Log',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_logsLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_myLogs.isEmpty)
                    Card(
                      color: Colors.grey.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "You haven't logged this route yet. Tap the button below to record your send!",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._myLogs.map((log) => _buildLogCard(log, showName: false)),

                  // Community sends
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Text(
                        'Community Sends',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (!_logsLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_communityLogs.length}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (!_logsLoading && _communityLogs.isEmpty)
                    Card(
                      color: Colors.grey.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.group_outlined, color: Colors.grey),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No one else has logged this route yet. Be the first!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (!_logsLoading)
                    ..._communityLogs.map((log) => _buildLogCard(log, showName: true)),

                  // Spacer for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Color routeColor) {
    return Container(
      color: routeColor.withOpacity(0.2),
      child: Center(
        child: Icon(
          Icons.terrain,
          size: 80,
          color: routeColor.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
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
