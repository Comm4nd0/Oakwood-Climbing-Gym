import 'package:flutter/material.dart';
import '../models/gym_class.dart';

class ClassCard extends StatelessWidget {
  final GymClass gymClass;

  const ClassCard({super.key, required this.gymClass});

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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gymClass.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(gymClass.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gymClass.difficultyDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(gymClass.difficulty),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              gymClass.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  gymClass.instructor,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${gymClass.durationMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(Icons.group, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Max ${gymClass.maxParticipants}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (gymClass.schedules.isNotEmpty) ...[
              const Divider(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: gymClass.schedules.map((schedule) {
                  return Chip(
                    label: Text(
                      '${schedule.dayOfWeekDisplay} ${schedule.startTime}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
