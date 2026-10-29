import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import 'mongo_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  StudentModel? _currentStudent;

  UserModel? get currentUser => _currentUser;
  StudentModel? get currentStudent => _currentStudent;

  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;

  Future<bool> login(String username, String password) async {
    final user = await MongoService().authenticate(username, password);
    if (user != null) {
      _currentUser = user;
      if (user.studentId != null) {
        _currentStudent = MongoService().getStudentById(user.studentId!);
      } else {
        _currentStudent = null;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _currentStudent = null;
    notifyListeners();
  }

  void refreshCurrentStudent() {
    if (_currentUser?.studentId != null) {
      _currentStudent = MongoService().getStudentById(_currentUser!.studentId!);
      notifyListeners();
    }
  }

  // Quick Demo Logins for Viva & Evaluation
  Future<void> demoLoginAdmin() async {
    await login('admin', 'admin123');
  }

  Future<void> demoLoginStudent() async {
    await login('rahul', 'student123');
  }
}
