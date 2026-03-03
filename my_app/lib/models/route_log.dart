class RouteLog {
  final int id;
  final int route;
  final String routeName;
  final String routeGrade;
  final String attemptType;
  final String attemptTypeDisplay;
  final int? rating;
  final String notes;
  final String loggedAt;

  RouteLog({
    required this.id,
    required this.route,
    required this.routeName,
    required this.routeGrade,
    required this.attemptType,
    required this.attemptTypeDisplay,
    this.rating,
    required this.notes,
    required this.loggedAt,
  });

  factory RouteLog.fromJson(Map<String, dynamic> json) {
    return RouteLog(
      id: json['id'],
      route: json['route'],
      routeName: json['route_name'] ?? '',
      routeGrade: json['route_grade'] ?? '',
      attemptType: json['attempt_type'],
      attemptTypeDisplay: json['attempt_type_display'] ?? json['attempt_type'],
      rating: json['rating'],
      notes: json['notes'] ?? '',
      loggedAt: json['logged_at'] ?? '',
    );
  }
}

class RouteStats {
  final int totalLogs;
  final int totalSends;
  final int totalFlashes;

  RouteStats({
    required this.totalLogs,
    required this.totalSends,
    required this.totalFlashes,
  });

  factory RouteStats.fromJson(Map<String, dynamic> json) {
    return RouteStats(
      totalLogs: json['total_logs'] ?? 0,
      totalSends: json['total_sends'] ?? 0,
      totalFlashes: json['total_flashes'] ?? 0,
    );
  }
}
