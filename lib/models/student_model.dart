class StudentModel {
  final String id; // Unique ID, e.g. STU1001
  final String name;
  final String gender;
  final String dob;
  final String college;
  final String course;
  final String year;
  final String rollNo;
  final String phone;
  final String email;
  final String parentName;
  final String parentPhone;
  final String address;
  final String admissionDate;
  final String? roomNumber; // null if not allocated
  final double feeAmount;
  final String emergencyContact;
  final String? photoUrl;

  StudentModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.dob,
    required this.college,
    required this.course,
    required this.year,
    required this.rollNo,
    required this.phone,
    required this.email,
    required this.parentName,
    required this.parentPhone,
    required this.address,
    required this.admissionDate,
    this.roomNumber,
    required this.feeAmount,
    required this.emergencyContact,
    this.photoUrl,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'ST';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  bool get isAllocated => roomNumber != null && roomNumber!.isNotEmpty;

  StudentModel copyWith({
    String? id,
    String? name,
    String? gender,
    String? dob,
    String? college,
    String? course,
    String? year,
    String? rollNo,
    String? phone,
    String? email,
    String? parentName,
    String? parentPhone,
    String? address,
    String? admissionDate,
    String? roomNumber,
    double? feeAmount,
    String? emergencyContact,
    String? photoUrl,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      college: college ?? this.college,
      course: course ?? this.course,
      year: year ?? this.year,
      rollNo: rollNo ?? this.rollNo,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      address: address ?? this.address,
      admissionDate: admissionDate ?? this.admissionDate,
      roomNumber: roomNumber ?? this.roomNumber,
      feeAmount: feeAmount ?? this.feeAmount,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'college': college,
      'course': course,
      'year': year,
      'roll_no': rollNo,
      'phone': phone,
      'email': email,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'address': address,
      'admission_date': admissionDate,
      'room_number': roomNumber,
      'fee_amount': feeAmount,
      'emergency_contact': emergencyContact,
      'photo_url': photoUrl,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['student_id']?.toString() ?? map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? 'Other',
      dob: map['dob'] ?? '',
      college: map['college'] ?? '',
      course: map['course'] ?? '',
      year: map['year'] ?? '',
      rollNo: map['roll_no'] ?? map['rollNo'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      parentName: map['parent_name'] ?? map['parentName'] ?? '',
      parentPhone: map['parent_phone'] ?? map['parentPhone'] ?? '',
      address: map['address'] ?? '',
      admissionDate: map['admission_date'] ?? map['admissionDate'] ?? '',
      roomNumber: map['room_number'] ?? map['roomNumber'],
      feeAmount: (map['fee_amount'] as num?)?.toDouble() ?? 
                 (map['feeAmount'] as num?)?.toDouble() ?? 0.0,
      emergencyContact: map['emergency_contact'] ?? map['emergencyContact'] ?? '',
      photoUrl: map['photo_url'] ?? map['photoUrl'],
    );
  }
}
