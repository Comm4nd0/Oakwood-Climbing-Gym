class Booking {
  final int id;
  final int classSchedule;
  final String className;
  final String date;
  final String status;
  final String statusDisplay;
  final String createdAt;

  Booking({
    required this.id,
    required this.classSchedule,
    required this.className,
    required this.date,
    required this.status,
    required this.statusDisplay,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      classSchedule: json['class_schedule'],
      className: json['class_name'] ?? '',
      date: json['date'],
      status: json['status'],
      statusDisplay: json['status_display'] ?? json['status'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
