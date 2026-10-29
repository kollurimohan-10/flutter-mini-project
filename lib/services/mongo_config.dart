class MongoConfig {
  static const String dbName = 'hostel_db';

  // Collection names in MongoDB
  static const String colUsers = 'users';
  static const String colStudents = 'students';
  static const String colRooms = 'rooms';
  static const String colAttendance = 'attendance';
  static const String colFees = 'fee_payments';
  static const String colComplaints = 'complaints';
  static const String colLeaves = 'leave_requests';
  static const String colAnnouncements = 'announcements';

  // Default URI options
  // For Android Emulator accessing localhost on host PC: 'mongodb://10.0.2.2:27017/hostel_db'
  // For Physical Device on same Wi-Fi or Desktop: 'mongodb://127.0.0.1:27017/hostel_db'
  // For MongoDB Atlas: 'mongodb+srv://<username>:<password>@cluster0.mongodb.net/hostel_db?retryWrites=true&w=majority'
  
  static String activeUri = 'mongodb://10.0.2.2:27017/hostel_db';

  static void setUri(String newUri) {
    activeUri = newUri.trim();
  }
}
