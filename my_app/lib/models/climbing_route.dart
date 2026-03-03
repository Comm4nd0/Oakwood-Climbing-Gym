class ClimbingRoute {
  final int id;
  final String name;
  final String grade;
  final String gradeSystem;
  final String color;
  final String colorDisplay;
  final int wallSection;
  final String wallSectionName;
  final String setter;
  final String dateSet;
  final String? dateRemoved;
  final String description;
  final String? image;
  final bool isActive;

  ClimbingRoute({
    required this.id,
    required this.name,
    required this.grade,
    required this.gradeSystem,
    required this.color,
    required this.colorDisplay,
    required this.wallSection,
    required this.wallSectionName,
    required this.setter,
    required this.dateSet,
    this.dateRemoved,
    required this.description,
    this.image,
    required this.isActive,
  });

  factory ClimbingRoute.fromJson(Map<String, dynamic> json) {
    return ClimbingRoute(
      id: json['id'],
      name: json['name'],
      grade: json['grade'],
      gradeSystem: json['grade_system'],
      color: json['color'],
      colorDisplay: json['color_display'] ?? json['color'],
      wallSection: json['wall_section'],
      wallSectionName: json['wall_section_name'] ?? '',
      setter: json['setter'],
      dateSet: json['date_set'],
      dateRemoved: json['date_removed'],
      description: json['description'] ?? '',
      image: json['image'],
      isActive: json['is_active'] ?? true,
    );
  }
}
