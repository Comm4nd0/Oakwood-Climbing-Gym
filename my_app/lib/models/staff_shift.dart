class StaffShift {
  final int id;
  final int staffMember;
  final String staffName;
  final String shiftType;
  final String shiftTypeDisplay;
  final String shiftRole;
  final String shiftRoleDisplay;
  final String date;
  final String startTime;
  final String endTime;
  final bool isKeyHolder;
  final String notes;

  StaffShift({
    required this.id,
    required this.staffMember,
    required this.staffName,
    required this.shiftType,
    required this.shiftTypeDisplay,
    required this.shiftRole,
    required this.shiftRoleDisplay,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isKeyHolder,
    required this.notes,
  });

  factory StaffShift.fromJson(Map<String, dynamic> json) {
    return StaffShift(
      id: json['id'],
      staffMember: json['staff_member'],
      staffName: json['staff_name'] ?? '',
      shiftType: json['shift_type'] ?? '',
      shiftTypeDisplay: json['shift_type_display'] ?? json['shift_type'] ?? '',
      shiftRole: json['shift_role'] ?? '',
      shiftRoleDisplay: json['shift_role_display'] ?? json['shift_role'] ?? '',
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isKeyHolder: json['is_key_holder'] ?? false,
      notes: json['notes'] ?? '',
    );
  }
}
