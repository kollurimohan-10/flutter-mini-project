class ComplaintModel {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status; // 'Pending', 'In Progress', 'Resolved'
  final String submissionDate;
  final String? resolutionNotes;

  ComplaintModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.submissionDate,
    this.resolutionNotes,
  });

  bool get isPending => status == 'Pending';
  bool get isInProgress => status == 'In Progress';
  bool get isResolved => status == 'Resolved';

  ComplaintModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? roomNumber,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? submissionDate,
    String? resolutionNotes,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      roomNumber: roomNumber ?? this.roomNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      submissionDate: submissionDate ?? this.submissionDate,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'complaint_id': id,
      'student_id': studentId,
      'student_name': studentName,
      'room_number': roomNumber,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'submission_date': submissionDate,
      'resolution_notes': resolutionNotes,
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    return ComplaintModel(
      id: map['complaint_id']?.toString() ?? map['_id']?.toString() ?? map['id']?.toString() ?? '',
      studentId: map['student_id'] ?? map['studentId'] ?? '',
      studentName: map['student_name'] ?? map['studentName'] ?? '',
      roomNumber: map['room_number'] ?? map['roomNumber'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      priority: map['priority'] ?? 'Medium',
      status: map['status'] ?? 'Pending',
      submissionDate: map['submission_date'] ?? map['submissionDate'] ?? '',
      resolutionNotes: map['resolution_notes'] ?? map['resolutionNotes'],
    );
  }
}
