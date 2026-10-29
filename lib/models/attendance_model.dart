class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String date; // YYYY-MM-DD
  final String status; // 'Present', 'Absent', 'On Leave'
  final String? remarks;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    this.remarks,
  });

  bool get isPresent => status == 'Present';
  bool get isAbsent => status == 'Absent';
  bool get isOnLeave => status == 'On Leave';

  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? date,
    String? status,
    String? remarks,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attendance_id': id,
      'student_id': studentId,
      'student_name': studentName,
      'date': date,
      'status': status,
      'remarks': remarks,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['attendance_id']?.toString() ?? map['_id']?.toString() ?? map['id']?.toString() ?? '',
      studentId: map['student_id'] ?? map['studentId'] ?? '',
      studentName: map['student_name'] ?? map['studentName'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'Present',
      remarks: map['remarks'],
    );
  }
}
