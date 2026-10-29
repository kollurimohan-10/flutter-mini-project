import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'mongo_config.dart';
import 'sample_data_service.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/room_model.dart';
import '../models/attendance_model.dart';
import '../models/fee_payment_model.dart';
import '../models/complaint_model.dart';
import '../models/leave_request_model.dart';
import '../models/announcement_model.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  mongo.Db? _db;
  bool _isConnected = false;
  String _lastError = '';

  // In-memory working cache (acts as local store & fallback if offline)
  List<UserModel> _users = [];
  List<StudentModel> _students = [];
  List<RoomModel> _rooms = [];
  List<AttendanceModel> _attendance = [];
  List<FeePaymentModel> _fees = [];
  List<ComplaintModel> _complaints = [];
  List<LeaveRequestModel> _leaves = [];
  List<AnnouncementModel> _announcements = [];

  bool get isConnected => _isConnected;
  String get lastError => _lastError;
  String get activeUri => MongoConfig.activeUri;

  /// Initialize and attempt MongoDB connection
  Future<void> init() async {
    // Populate working memory with standard sample dataset first
    _populateMemoryFromSample();

    // Attempt live connection
    await connect(MongoConfig.activeUri);
  }

  void _populateMemoryFromSample() {
    _users = SampleDataService.getInitialUsers();
    _students = SampleDataService.getInitialStudents();
    _rooms = SampleDataService.getInitialRooms();
    _attendance = SampleDataService.getInitialAttendance();
    _fees = SampleDataService.getInitialFeePayments();
    _complaints = SampleDataService.getInitialComplaints();
    _leaves = SampleDataService.getInitialLeaveRequests();
    _announcements = SampleDataService.getInitialAnnouncements();
  }

  /// Connect to MongoDB instance
  Future<bool> connect(String uri) async {
    try {
      MongoConfig.setUri(uri);
      if (_db != null && _db!.isConnected) {
        await _db!.close();
      }

      _db = await mongo.Db.create(uri);
      // Timeout after 4 seconds so UI stays responsive if host unreachable
      await _db!.open().timeout(const Duration(seconds: 4));
      _isConnected = true;
      _lastError = '';
      debugPrint('Connected successfully to MongoDB at $uri');

      // Sync data from remote MongoDB if collections exist
      await _loadFromMongo();
      return true;
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      debugPrint('MongoDB connection note (operating in offline demo mode): $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_db != null) {
        await _db!.close();
        _isConnected = false;
      }
    } catch (e) {
      debugPrint('Error disconnecting MongoDB: $e');
    }
  }

  /// Load collections from MongoDB into memory
  Future<void> _loadFromMongo() async {
    if (!_isConnected || _db == null) return;
    try {
      final stuCol = _db!.collection(MongoConfig.colStudents);
      final stuDocs = await stuCol.find().toList();
      if (stuDocs.isNotEmpty) {
        _students = stuDocs.map((d) => StudentModel.fromMap(d)).toList();
      }

      final roomCol = _db!.collection(MongoConfig.colRooms);
      final roomDocs = await roomCol.find().toList();
      if (roomDocs.isNotEmpty) {
        _rooms = roomDocs.map((d) => RoomModel.fromMap(d)).toList();
      }

      final attCol = _db!.collection(MongoConfig.colAttendance);
      final attDocs = await attCol.find().toList();
      if (attDocs.isNotEmpty) {
        _attendance = attDocs.map((d) => AttendanceModel.fromMap(d)).toList();
      }

      final feeCol = _db!.collection(MongoConfig.colFees);
      final feeDocs = await feeCol.find().toList();
      if (feeDocs.isNotEmpty) {
        _fees = feeDocs.map((d) => FeePaymentModel.fromMap(d)).toList();
      }

      final cmpCol = _db!.collection(MongoConfig.colComplaints);
      final cmpDocs = await cmpCol.find().toList();
      if (cmpDocs.isNotEmpty) {
        _complaints = cmpDocs.map((d) => ComplaintModel.fromMap(d)).toList();
      }

      final levCol = _db!.collection(MongoConfig.colLeaves);
      final levDocs = await levCol.find().toList();
      if (levDocs.isNotEmpty) {
        _leaves = levDocs.map((d) => LeaveRequestModel.fromMap(d)).toList();
      }

      final annCol = _db!.collection(MongoConfig.colAnnouncements);
      final annDocs = await annCol.find().toList();
      if (annDocs.isNotEmpty) {
        _announcements = annDocs.map((d) => AnnouncementModel.fromMap(d)).toList();
      }

      final usrCol = _db!.collection(MongoConfig.colUsers);
      final usrDocs = await usrCol.find().toList();
      if (usrDocs.isNotEmpty) {
        _users = usrDocs.map((d) => UserModel.fromMap(d)).toList();
      }
    } catch (e) {
      debugPrint('Failed loading collections from MongoDB: $e');
    }
  }

  /// Seed / Reset all sample data to MongoDB
  Future<void> seedDatabase() async {
    _populateMemoryFromSample();

    if (_isConnected && _db != null) {
      try {
        final tables = [
          MongoConfig.colUsers,
          MongoConfig.colStudents,
          MongoConfig.colRooms,
          MongoConfig.colAttendance,
          MongoConfig.colFees,
          MongoConfig.colComplaints,
          MongoConfig.colLeaves,
          MongoConfig.colAnnouncements,
        ];

        for (final t in tables) {
          try {
            await _db!.collection(t).drop();
          } catch (_) {}
        }

        // Insert new records
        await _db!.collection(MongoConfig.colUsers).insertAll(_users.map((u) => u.toMap()).toList());
        await _db!.collection(MongoConfig.colStudents).insertAll(_students.map((s) => s.toMap()).toList());
        await _db!.collection(MongoConfig.colRooms).insertAll(_rooms.map((r) => r.toMap()).toList());
        await _db!.collection(MongoConfig.colAttendance).insertAll(_attendance.map((a) => a.toMap()).toList());
        await _db!.collection(MongoConfig.colFees).insertAll(_fees.map((f) => f.toMap()).toList());
        await _db!.collection(MongoConfig.colComplaints).insertAll(_complaints.map((c) => c.toMap()).toList());
        await _db!.collection(MongoConfig.colLeaves).insertAll(_leaves.map((l) => l.toMap()).toList());
        await _db!.collection(MongoConfig.colAnnouncements).insertAll(_announcements.map((a) => a.toMap()).toList());

        debugPrint('MongoDB seeded successfully!');
      } catch (e) {
        debugPrint('Error writing seed to MongoDB: $e');
      }
    }
  }

  // ================= USERS & AUTH =================
  Future<UserModel?> authenticate(String username, String password) async {
    final cleanUser = username.trim().toLowerCase();
    final cleanPass = password.trim();

    try {
      return _users.firstWhere(
        (u) => u.username.toLowerCase() == cleanUser && u.password == cleanPass,
      );
    } catch (_) {
      return null;
    }
  }

  UserModel? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id || u.studentId == id);
    } catch (_) {
      return null;
    }
  }

  // ================= STUDENTS CRUD =================
  List<StudentModel> getStudents() => List.unmodifiable(_students);

  StudentModel? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isStudentIdTaken(String id, [String? currentId]) {
    return _students.any((s) => s.id.toLowerCase() == id.toLowerCase() && s.id != currentId);
  }

  bool isRollNoTaken(String rollNo, [String? currentId]) {
    return _students.any((s) => s.rollNo.toLowerCase() == rollNo.toLowerCase() && s.id != currentId);
  }

  Future<void> addStudent(StudentModel student) async {
    _students.add(student);
    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colStudents).insertOne(student.toMap());
      } catch (e) {
        debugPrint('MongoDB addStudent error: $e');
      }
    }
    // If student has an assigned room, update room occupancy
    if (student.roomNumber != null) {
      await _recalculateRoomOccupancy(student.roomNumber!);
    }
  }

  Future<void> updateStudent(StudentModel student) async {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      final oldRoom = _students[index].roomNumber;
      _students[index] = student;

      if (_isConnected && _db != null) {
        try {
          await _db!.collection(MongoConfig.colStudents).update(
            mongo.where.eq('student_id', student.id),
            student.toMap(),
          );
        } catch (e) {
          debugPrint('MongoDB updateStudent error: $e');
        }
      }

      if (oldRoom != student.roomNumber) {
        if (oldRoom != null) await _recalculateRoomOccupancy(oldRoom);
        if (student.roomNumber != null) await _recalculateRoomOccupancy(student.roomNumber!);
      }
    }
  }

  Future<void> deleteStudent(String studentId) async {
    final student = getStudentById(studentId);
    final roomNo = student?.roomNumber;

    _students.removeWhere((s) => s.id == studentId);
    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colStudents).remove(mongo.where.eq('student_id', studentId));
      } catch (e) {
        debugPrint('MongoDB deleteStudent error: $e');
      }
    }

    if (roomNo != null) {
      await _recalculateRoomOccupancy(roomNo);
    }
  }

  // ================= ROOMS CRUD =================
  List<RoomModel> getRooms() => List.unmodifiable(_rooms);

  RoomModel? getRoomByNumber(String roomNumber) {
    try {
      return _rooms.firstWhere((r) => r.roomNumber.toLowerCase() == roomNumber.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  List<StudentModel> getStudentsInRoom(String roomNumber) {
    return _students.where((s) => s.roomNumber != null && s.roomNumber!.toLowerCase() == roomNumber.toLowerCase()).toList();
  }

  Future<void> addRoom(RoomModel room) async {
    _rooms.add(room);
    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colRooms).insertOne(room.toMap());
      } catch (e) {
        debugPrint('MongoDB addRoom error: $e');
      }
    }
  }

  Future<void> updateRoom(RoomModel room) async {
    final idx = _rooms.indexWhere((r) => r.id == room.id);
    if (idx != -1) {
      _rooms[idx] = room;
      if (_isConnected && _db != null) {
        try {
          await _db!.collection(MongoConfig.colRooms).update(
            mongo.where.eq('room_id', room.id),
            room.toMap(),
          );
        } catch (e) {
          debugPrint('MongoDB updateRoom error: $e');
        }
      }
    }
  }

  Future<void> deleteRoom(String roomId) async {
    final room = _rooms.firstWhere((r) => r.id == roomId, orElse: () => RoomModel(id: '', roomNumber: '', floor: 1, roomType: '', totalBeds: 0, occupiedBeds: 0, monthlyFee: 0));
    _rooms.removeWhere((r) => r.id == roomId);
    // Unassign students from this room
    for (int i = 0; i < _students.length; i++) {
      if (_students[i].roomNumber == room.roomNumber) {
        _students[i] = _students[i].copyWith(roomNumber: null);
      }
    }

    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colRooms).remove(mongo.where.eq('room_id', roomId));
      } catch (e) {
        debugPrint('MongoDB deleteRoom error: $e');
      }
    }
  }

  Future<bool> allocateStudentToRoom(String studentId, String roomNumber) async {
    final room = getRoomByNumber(roomNumber);
    final student = getStudentById(studentId);
    if (room == null || student == null) return false;

    // Check if room has bed space
    final currentOccupants = getStudentsInRoom(roomNumber);
    if (currentOccupants.length >= room.totalBeds) {
      return false; // Room is full!
    }

    final oldRoom = student.roomNumber;
    final updatedStudent = student.copyWith(roomNumber: roomNumber);
    await updateStudent(updatedStudent);

    await _recalculateRoomOccupancy(roomNumber);
    if (oldRoom != null && oldRoom != roomNumber) {
      await _recalculateRoomOccupancy(oldRoom);
    }
    return true;
  }

  Future<void> vacateStudent(String studentId) async {
    final student = getStudentById(studentId);
    if (student != null && student.roomNumber != null) {
      final oldRoom = student.roomNumber!;
      final updated = student.copyWith(roomNumber: '');
      await updateStudent(updated);
      await _recalculateRoomOccupancy(oldRoom);
    }
  }

  Future<void> _recalculateRoomOccupancy(String roomNumber) async {
    final idx = _rooms.indexWhere((r) => r.roomNumber.toLowerCase() == roomNumber.toLowerCase());
    if (idx != -1) {
      final count = _students.where((s) => s.roomNumber != null && s.roomNumber!.toLowerCase() == roomNumber.toLowerCase()).length;
      final updatedRoom = _rooms[idx].copyWith(occupiedBeds: count);
      _rooms[idx] = updatedRoom;

      if (_isConnected && _db != null) {
        try {
          await _db!.collection(MongoConfig.colRooms).update(
            mongo.where.eq('room_number', roomNumber),
            updatedRoom.toMap(),
          );
        } catch (e) {
          debugPrint('MongoDB room recalculation error: $e');
        }
      }
    }
  }

  // ================= ATTENDANCE =================
  List<AttendanceModel> getAttendanceByDate(String date) {
    return _attendance.where((a) => a.date == date).toList();
  }

  List<AttendanceModel> getStudentAttendance(String studentId) {
    return _attendance.where((a) => a.studentId == studentId).toList();
  }

  double calculateAttendancePercentage(String studentId) {
    final records = getStudentAttendance(studentId);
    if (records.isEmpty) return 100.0;
    final presentCount = records.where((r) => r.status == 'Present' || r.status == 'On Leave').length;
    return (presentCount / records.length) * 100.0;
  }

  Future<void> saveAttendanceBatch(List<AttendanceModel> newRecords) async {
    for (final record in newRecords) {
      final idx = _attendance.indexWhere(
        (a) => a.studentId == record.studentId && a.date == record.date,
      );
      if (idx != -1) {
        _attendance[idx] = record;
      } else {
        _attendance.add(record);
      }
    }

    if (_isConnected && _db != null) {
      try {
        final col = _db!.collection(MongoConfig.colAttendance);
        for (final r in newRecords) {
          await col.update(
            mongo.where.eq('student_id', r.studentId).and(mongo.where.eq('date', r.date)),
            r.toMap(),
            upsert: true,
          );
        }
      } catch (e) {
        debugPrint('MongoDB saveAttendance error: $e');
      }
    }
  }

  // ================= FEES & PAYMENTS =================
  List<FeePaymentModel> getFeePayments() => List.unmodifiable(_fees);

  List<FeePaymentModel> getPaymentsForStudent(String studentId) {
    return _fees.where((f) => f.studentId == studentId).toList();
  }

  double getTotalPaidForStudent(String studentId) {
    return _fees
        .where((f) => f.studentId == studentId)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getDueAmountForStudent(String studentId) {
    final student = getStudentById(studentId);
    if (student == null) return 0.0;
    final paid = getTotalPaidForStudent(studentId);
    final due = student.feeAmount - paid;
    return due < 0 ? 0.0 : due;
  }

  String getPaymentStatusForStudent(String studentId) {
    final student = getStudentById(studentId);
    if (student == null) return 'N/A';
    final paid = getTotalPaidForStudent(studentId);
    if (paid >= student.feeAmount) return 'Fully Paid';
    if (paid > 0) return 'Partially Paid';
    return 'Pending';
  }

  Future<void> addFeePayment(FeePaymentModel payment) async {
    _fees.insert(0, payment);
    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colFees).insertOne(payment.toMap());
      } catch (e) {
        debugPrint('MongoDB addFeePayment error: $e');
      }
    }
  }

  // ================= COMPLAINTS =================
  List<ComplaintModel> getComplaints() => List.unmodifiable(_complaints);

  List<ComplaintModel> getComplaintsForStudent(String studentId) {
    return _complaints.where((c) => c.studentId == studentId).toList();
  }

  Future<void> addComplaint(ComplaintModel complaint) async {
    _complaints.insert(0, complaint);
    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colComplaints).insertOne(complaint.toMap());
      } catch (e) {
        debugPrint('MongoDB addComplaint error: $e');
      }
    }
  }

  Future<void> updateComplaintStatus(String id, String newStatus, [String? notes]) async {
    final idx = _complaints.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _complaints[idx] = _complaints[idx].copyWith(
        status: newStatus,
        resolutionNotes: notes ?? _complaints[idx].resolutionNotes,
      );

      if (_isConnected && _db != null) {
        try {
          await _db!.collection(MongoConfig.colComplaints).update(
            mongo.where.eq('complaint_id', id),
            _complaints[idx].toMap(),
          );
        } catch (e) {
          debugPrint('MongoDB updateComplaint error: $e');
        }
      }
    }
  }

  // ================= LEAVE REQUESTS =================
  List<LeaveRequestModel> getLeaveRequests() => List.unmodifiable(_leaves);

  List<LeaveRequestModel> getLeavesForStudent(String studentId) {
    return _leaves.where((l) => l.studentId == studentId).toList();
  }

  Future<void> addLeaveRequest(LeaveRequestModel leave) async {
    _leaves.insert(0, leave);
    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colLeaves).insertOne(leave.toMap());
      } catch (e) {
        debugPrint('MongoDB addLeaveRequest error: $e');
      }
    }
  }

  Future<void> updateLeaveStatus(String id, String status, [String? notes]) async {
    final idx = _leaves.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _leaves[idx] = _leaves[idx].copyWith(
        status: status,
        decisionNotes: notes ?? _leaves[idx].decisionNotes,
      );

      if (_isConnected && _db != null) {
        try {
          await _db!.collection(MongoConfig.colLeaves).update(
            mongo.where.eq('leave_id', id),
            _leaves[idx].toMap(),
          );
        } catch (e) {
          debugPrint('MongoDB updateLeave error: $e');
        }
      }
    }
  }

  // ================= ANNOUNCEMENTS =================
  List<AnnouncementModel> getAnnouncements() => List.unmodifiable(_announcements);

  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    _announcements.insert(0, announcement);
    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colAnnouncements).insertOne(announcement.toMap());
      } catch (e) {
        debugPrint('MongoDB addAnnouncement error: $e');
      }
    }
  }

  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    final idx = _announcements.indexWhere((a) => a.id == announcement.id);
    if (idx != -1) {
      _announcements[idx] = announcement;
      if (_isConnected && _db != null) {
        try {
          await _db!.collection(MongoConfig.colAnnouncements).update(
            mongo.where.eq('announcement_id', announcement.id),
            announcement.toMap(),
          );
        } catch (e) {
          debugPrint('MongoDB updateAnnouncement error: $e');
        }
      }
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    _announcements.removeWhere((a) => a.id == id);
    if (_isConnected && _db != null) {
      try {
        await _db!.collection(MongoConfig.colAnnouncements).remove(mongo.where.eq('announcement_id', id));
      } catch (e) {
        debugPrint('MongoDB deleteAnnouncement error: $e');
      }
    }
  }

  // ================= STATS & AGGREGATIONS =================
  int get totalStudents => _students.length;
  int get totalRooms => _rooms.length;
  int get occupiedRooms => _rooms.where((r) => r.occupiedBeds > 0).length;
  int get totalBeds => _rooms.fold(0, (sum, r) => sum + r.totalBeds);
  int get occupiedBeds => _rooms.fold(0, (sum, r) => sum + r.occupiedBeds);
  int get availableBeds => (totalBeds - occupiedBeds).clamp(0, totalBeds);

  double get totalExpectedFees => _students.fold(0.0, (sum, s) => sum + s.feeAmount);
  double get totalCollectedFees => _fees.fold(0.0, (sum, f) => sum + f.amount);
  double get totalPendingFees => (totalExpectedFees - totalCollectedFees).clamp(0.0, double.infinity);

  int get pendingComplaintsCount => _complaints.where((c) => c.status != 'Resolved').length;
  int get pendingLeavesCount => _leaves.where((l) => l.status == 'Pending').length;
}
