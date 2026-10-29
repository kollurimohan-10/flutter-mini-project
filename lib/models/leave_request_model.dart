class LeaveRequestModel {
  final String id;
  final String studentId;
  final String studentName;
  final String startDate;
  final String returnDate;
  final String reason;
  final String parentContact;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String? decisionNotes;
  final String appliedDate;

  LeaveRequestModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.startDate,
    required this.returnDate,
    required this.reason,
    required this.parentContact,
    required this.status,
    this.decisionNotes,
    required this.appliedDate,
  });

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';

  LeaveRequestModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? startDate,
    String? returnDate,
    String? reason,
    String? parentContact,
    String? status,
    String? decisionNotes,
    String? appliedDate,
  }) {
    return LeaveRequestModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      startDate: startDate ?? this.startDate,
      returnDate: returnDate ?? this.returnDate,
      reason: reason ?? this.reason,
      parentContact: parentContact ?? this.parentContact,
      status: status ?? this.status,
      decisionNotes: decisionNotes ?? this.decisionNotes,
      appliedDate: appliedDate ?? this.appliedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leave_id': id,
      'student_id': studentId,
      'student_name': studentName,
      'start_date': startDate,
      'return_date': returnDate,
      'reason': reason,
      'parent_contact': parentContact,
      'status': status,
      'decision_notes': decisionNotes,
      'applied_date': appliedDate,
    };
  }

  factory LeaveRequestModel.fromMap(Map<String, dynamic> map) {
    return LeaveRequestModel(
      id: map['leave_id']?.toString() ?? map['_id']?.toString() ?? map['id']?.toString() ?? '',
      studentId: map['student_id'] ?? map['studentId'] ?? '',
      studentName: map['student_name'] ?? map['studentName'] ?? '',
      startDate: map['start_date'] ?? map['startDate'] ?? '',
      returnDate: map['return_date'] ?? map['returnDate'] ?? '',
      reason: map['reason'] ?? '',
      parentContact: map['parent_contact'] ?? map['parentContact'] ?? '',
      status: map['status'] ?? 'Pending',
      decisionNotes: map['decision_notes'] ?? map['decisionNotes'],
      appliedDate: map['applied_date'] ?? map['appliedDate'] ?? '',
    );
  }
}
