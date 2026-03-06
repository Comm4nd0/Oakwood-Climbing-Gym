class TicketMessage {
  final int id;
  final int ticket;
  final int sender;
  final String senderName;
  final String body;
  final bool isStaffReply;
  final String createdAt;

  TicketMessage({
    required this.id,
    required this.ticket,
    required this.sender,
    required this.senderName,
    required this.body,
    required this.isStaffReply,
    required this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'],
      ticket: json['ticket'],
      sender: json['sender'],
      senderName: json['sender_name'] ?? '',
      body: json['body'] ?? '',
      isStaffReply: json['is_staff_reply'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class SupportTicket {
  final int id;
  final int user;
  final String userName;
  final String subject;
  final String category;
  final String categoryDisplay;
  final String status;
  final String statusDisplay;
  final String priority;
  final String priorityDisplay;
  final String createdAt;
  final String updatedAt;
  final List<TicketMessage> messages;
  final int messageCount;

  SupportTicket({
    required this.id,
    required this.user,
    required this.userName,
    required this.subject,
    required this.category,
    required this.categoryDisplay,
    required this.status,
    required this.statusDisplay,
    required this.priority,
    required this.priorityDisplay,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    required this.messageCount,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      user: json['user'],
      userName: json['user_name'] ?? '',
      subject: json['subject'] ?? '',
      category: json['category'] ?? 'general',
      categoryDisplay: json['category_display'] ?? json['category'] ?? '',
      status: json['status'] ?? 'open',
      statusDisplay: json['status_display'] ?? json['status'] ?? '',
      priority: json['priority'] ?? 'medium',
      priorityDisplay: json['priority_display'] ?? json['priority'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      messages: (json['messages'] as List?)
              ?.map((m) => TicketMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      messageCount: json['message_count'] ?? 0,
    );
  }
}
