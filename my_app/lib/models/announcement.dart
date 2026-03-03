class Announcement {
  final int id;
  final String title;
  final String content;
  final String priority;
  final String? image;
  final bool isPublished;
  final String publishDate;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    this.image,
    required this.isPublished,
    required this.publishDate,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      priority: json['priority'] ?? 'normal',
      image: json['image'],
      isPublished: json['is_published'] ?? true,
      publishDate: json['publish_date'] ?? '',
    );
  }
}
