class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String date;
  final String priority; // 'Normal', 'Urgent'
  final String author;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.priority,
    required this.author,
  });

  bool get isUrgent => priority == 'Urgent';

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? message,
    String? date,
    String? priority,
    String? author,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'announcement_id': id,
      'title': title,
      'message': message,
      'date': date,
      'priority': priority,
      'author': author,
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['announcement_id']?.toString() ?? map['_id']?.toString() ?? map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      date: map['date'] ?? '',
      priority: map['priority'] ?? 'Normal',
      author: map['author'] ?? 'Hostel Administration',
    );
  }
}
