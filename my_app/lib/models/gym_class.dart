class ClassSchedule {
  final int id;
  final int dayOfWeek;
  final String dayOfWeekDisplay;
  final String startTime;
  final bool isActive;

  ClassSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.dayOfWeekDisplay,
    required this.startTime,
    required this.isActive,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      dayOfWeekDisplay: json['day_of_week_display'] ?? '',
      startTime: json['start_time'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class GymClass {
  final int id;
  final String name;
  final String description;
  final String instructor;
  final String difficulty;
  final String difficultyDisplay;
  final int maxParticipants;
  final int durationMinutes;
  final String? image;
  final bool isActive;
  final List<ClassSchedule> schedules;

  GymClass({
    required this.id,
    required this.name,
    required this.description,
    required this.instructor,
    required this.difficulty,
    required this.difficultyDisplay,
    required this.maxParticipants,
    required this.durationMinutes,
    this.image,
    required this.isActive,
    required this.schedules,
  });

  factory GymClass.fromJson(Map<String, dynamic> json) {
    return GymClass(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      instructor: json['instructor'],
      difficulty: json['difficulty'],
      difficultyDisplay: json['difficulty_display'] ?? json['difficulty'],
      maxParticipants: json['max_participants'],
      durationMinutes: json['duration_minutes'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
      schedules: (json['schedules'] as List? ?? [])
          .map((s) => ClassSchedule.fromJson(s))
          .toList(),
    );
  }
}
