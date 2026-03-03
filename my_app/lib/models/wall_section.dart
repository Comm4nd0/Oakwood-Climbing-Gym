class WallSection {
  final int id;
  final String name;
  final String description;
  final String wallType;
  final String wallTypeDisplay;
  final String? image;
  final bool isActive;
  final int routeCount;

  WallSection({
    required this.id,
    required this.name,
    required this.description,
    required this.wallType,
    required this.wallTypeDisplay,
    this.image,
    required this.isActive,
    required this.routeCount,
  });

  factory WallSection.fromJson(Map<String, dynamic> json) {
    return WallSection(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      wallType: json['wall_type'],
      wallTypeDisplay: json['wall_type_display'] ?? json['wall_type'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
      routeCount: json['route_count'] ?? 0,
    );
  }
}
