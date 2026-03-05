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
  final String classType;
  final String classTypeDisplay;
  final String description;
  final String instructor;
  final String difficulty;
  final String difficultyDisplay;
  final String ageGroup;
  final String ageGroupDisplay;
  final int maxParticipants;
  final int durationMinutes;
  final double price;
  final bool includesShoeHire;
  final String? image;
  final bool isActive;
  final List<ClassSchedule> schedules;

  GymClass({
    required this.id,
    required this.name,
    required this.classType,
    required this.classTypeDisplay,
    required this.description,
    required this.instructor,
    required this.difficulty,
    required this.difficultyDisplay,
    required this.ageGroup,
    required this.ageGroupDisplay,
    required this.maxParticipants,
    required this.durationMinutes,
    required this.price,
    required this.includesShoeHire,
    this.image,
    required this.isActive,
    required this.schedules,
  });

  factory GymClass.fromJson(Map<String, dynamic> json) {
    return GymClass(
      id: json['id'],
      name: json['name'],
      classType: json['class_type'] ?? '',
      classTypeDisplay: json['class_type_display'] ?? json['class_type'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor_name'] ?? json['instructor']?.toString() ?? '',
      difficulty: json['difficulty'],
      difficultyDisplay: json['difficulty_display'] ?? json['difficulty'],
      ageGroup: json['age_group'] ?? 'adult',
      ageGroupDisplay: json['age_group_display'] ?? json['age_group'] ?? '',
      maxParticipants: json['max_participants'],
      durationMinutes: json['duration_minutes'],
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      includesShoeHire: json['includes_shoe_hire'] ?? false,
      image: json['image'],
      isActive: json['is_active'] ?? true,
      schedules: (json['schedules'] as List? ?? [])
          .map((s) => ClassSchedule.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'class_type': classType,
      'description': description,
      'difficulty': difficulty,
      'age_group': ageGroup,
      'max_participants': maxParticipants,
      'duration_minutes': durationMinutes,
      'price': price.toStringAsFixed(2),
      'includes_shoe_hire': includesShoeHire,
    };
  }
}
