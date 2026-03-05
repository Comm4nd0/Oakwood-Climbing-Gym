import 'package:flutter/material.dart';
import '../models/climbing_route.dart';
import '../utils/grade_converter.dart';

class RouteCard extends StatelessWidget {
  final ClimbingRoute route;
  final VoidCallback? onTap;

  const RouteCard({super.key, required this.route, this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final converted = GradeConverter.convertGrade(route.grade, route.gradeSystem);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 12,
                height: 60,
                decoration: BoxDecoration(
                  color: _getRouteColor(route.color),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 16),
              // Route info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${route.wallSectionName} | Set by ${route.setter}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (route.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        route.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              // Grade badge — dual display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route.grade,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (converted != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        converted,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
