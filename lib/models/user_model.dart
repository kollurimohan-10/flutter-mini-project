class UserModel {
  final String id;
  final String username;
  final String password;
  final String role; // 'admin' or 'student'
  final String? studentId;
  final String? name;
  final String? email;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.studentId,
    this.name,
    this.email,
  });

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'student_id': studentId,
      'name': name,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'student',
      studentId: map['student_id'] ?? map['studentId'],
      name: map['name'],
      email: map['email'],
    );
  }
}
