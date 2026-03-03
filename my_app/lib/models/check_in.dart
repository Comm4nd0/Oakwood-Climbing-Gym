class CheckInRecord {
  final int id;
  final int? member;
  final String visitorName;
  final String memberName;
  final String entryType;
  final String checkedInAt;
  final String? checkedOutAt;

  CheckInRecord({
    required this.id,
    this.member,
    required this.visitorName,
    required this.memberName,
    required this.entryType,
    required this.checkedInAt,
    this.checkedOutAt,
  });

  bool get isCurrentlyIn => checkedOutAt == null;

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    return CheckInRecord(
      id: json['id'],
      member: json['member'],
      visitorName: json['visitor_name'] ?? '',
      memberName: json['member_name'] ?? json['visitor_name'] ?? '',
      entryType: json['entry_type'] ?? '',
      checkedInAt: json['checked_in_at'] ?? '',
      checkedOutAt: json['checked_out_at'],
    );
  }
}
