import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/climbing_route.dart';
import '../utils/grade_converter.dart';
import '../widgets/route_card.dart';
import 'route_detail_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<ClimbingRoute> _routes = [];
  bool _isLoading = true;
  String? _error;

  // Filter / sort state
  String? _selectedColor;
  String _sortBy = 'name'; // 'name', 'grade_asc', 'grade_desc'

  static const _colorOptions = [
    ('red', 'Red', Colors.red),
    ('blue', 'Blue', Colors.blue),
    ('green', 'Green', Colors.green),
    ('yellow', 'Yellow', Color(0xFFF9A825)),
    ('orange', 'Orange', Colors.orange),
    ('purple', 'Purple', Colors.purple),
    ('pink', 'Pink', Colors.pink),
    ('white', 'White', Color(0xFFBDBDBD)),
    ('black', 'Black', Color(0xFF424242)),
  ];

  int _gradeIndex(ClimbingRoute route) {
    return GradeConverter.sortIndex(route.grade, route.gradeSystem);
  }

  List<ClimbingRoute> get _filteredRoutes {
    var result = List<ClimbingRoute>.from(_routes);

    // Colour filter
    if (_selectedColor != null) {
      result = result.where((r) => r.color == _selectedColor).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'grade_asc':
        result.sort((a, b) => _gradeIndex(a).compareTo(_gradeIndex(b)));
        break;
      case 'grade_desc':
        result.sort((a, b) => _gradeIndex(b).compareTo(_gradeIndex(a)));
        break;
      default:
        result.sort((a, b) => a.name.compareTo(b.name));
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final routes = await apiService.getRoutes();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load routes. Pull to refresh.';
        _isLoading = false;
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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

                  // Title row
                  Row(
                    children: [
                      Text(
                        'Filter & Sort',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedColor = null;
                            _sortBy = 'name';
                          });
                          setSheetState(() {});
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Colour filter
                  Text(
                    'Colour',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // "All" chip
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedColor == null,
                        onSelected: (_) {
                          setState(() => _selectedColor = null);
                          setSheetState(() {});
                        },
                      ),
                      ..._colorOptions.map((opt) {
                        final (key, label, color) = opt;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(label),
                            ],
                          ),
                          selected: _selectedColor == key,
                          onSelected: (_) {
                            setState(() => _selectedColor = key);
                            setSheetState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort
                  Text(
                    'Sort by',
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
                        label: const Text('Name'),
                        selected: _sortBy == 'name',
                        onSelected: (_) {
                          setState(() => _sortBy = 'name');
                          setSheetState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Grade ↑'),
                        selected: _sortBy == 'grade_asc',
                        onSelected: (_) {
                          setState(() => _sortBy = 'grade_asc');
                          setSheetState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Grade ↓'),
                        selected: _sortBy == 'grade_desc',
                        onSelected: (_) {
                          setState(() => _sortBy = 'grade_desc');
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRoutes;
    final hasActiveFilter = _selectedColor != null || _sortBy != 'name';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (hasActiveFilter)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRoutes,
        child: _buildBody(filtered),
      ),
    );
  }

  Widget _buildBody(List<ClimbingRoute> routes) {
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
            ElevatedButton(
              onPressed: _loadRoutes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_routes.isEmpty) {
      return const Center(
        child: Text('No routes available right now.'),
      );
    }

    if (routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No routes match your filters.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedColor = null;
                  _sortBy = 'name';
                });
              },
              child: const Text('Clear filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return RouteCard(
          route: route,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RouteDetailScreen(route: route),
              ),
            );
          },
        );
      },
    );
  }
}
