class AppConstants {
  static const String appName = 'Hostel Mate';
  static const String appSubtitle = 'Hostel Student Management System';
  static const String collegeName = 'National Institute of Technology';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'student';

  // Room Types
  static const List<String> roomTypes = ['AC Standard', 'Non-AC Deluxe', 'Non-AC Standard'];
  
  // Room Statuses
  static const String roomAvailable = 'Available';
  static const String roomPartial = 'Partially Occupied';
  static const String roomFull = 'Full';

  // Attendance Statuses
  static const String attPresent = 'Present';
  static const String attAbsent = 'Absent';
  static const String attLeave = 'On Leave';

  // Complaint Categories
  static const List<String> complaintCategories = [
    'Electricity',
    'Water Supply',
    'Food / Mess',
    'Room Cleaning',
    'Wi-Fi / Internet',
    'Plumbing',
    'Carpentry',
    'Other'
  ];

  // Complaint Priorities
  static const List<String> priorities = ['Low', 'Medium', 'High', 'Emergency'];

  // Complaint Statuses
  static const String complaintPending = 'Pending';
  static const String complaintInProgress = 'In Progress';
  static const String complaintResolved = 'Resolved';

  // Leave Statuses
  static const String leavePending = 'Pending';
  static const String leaveApproved = 'Approved';
  static const String leaveRejected = 'Rejected';

  // Payment Methods
  static const List<String> paymentMethods = ['UPI / GPay', 'Cash', 'Net Banking', 'Debit/Credit Card', 'Demand Draft'];

  // Hostel Rules
  static const List<Map<String, String>> hostelRules = [
    {
      'title': 'Curfew Timings',
      'desc': 'Hostel main gate will close promptly at 9:00 PM on weekdays and 9:30 PM on weekends. Late entry requires prior warden approval.'
    },
    {
      'title': 'Visitor Policy',
      'desc': 'Parents and guardians can visit between 4:00 PM and 7:00 PM in the reception lobby. Outside guests are strictly not allowed inside student rooms.'
    },
    {
      'title': 'Quiet Hours',
      'desc': 'Quiet study hours are strictly observed from 10:00 PM to 6:00 AM. Loud music and disturbance to roommates is prohibited.'
    },
    {
      'title': 'Electrical Appliances',
      'desc': 'High-power appliances like electric heaters, induction stoves, and immersion rods are strictly banned in rooms.'
    },
    {
      'title': 'Ragging / Misconduct',
      'desc': 'Zero-tolerance policy against ragging, harassment, alcohol, or illicit substance consumption with immediate expulsion.'
    },
  ];

  // Mess Timings
  static const List<Map<String, String>> messTimings = [
    {'meal': 'Breakfast', 'time': '7:30 AM - 9:00 AM', 'menu': 'Idli, Dosa, Poha, Bread Omelette, Tea & Coffee'},
    {'meal': 'Lunch', 'time': '12:30 PM - 2:00 PM', 'menu': 'Rice, Chapati, Dal Tadka, Paneer / Chicken curry, Curd'},
    {'meal': 'Evening Snacks', 'time': '5:00 PM - 6:00 PM', 'menu': 'Samosa / Biscuits, Hot Tea & Coffee'},
    {'meal': 'Dinner', 'time': '7:30 PM - 9:00 PM', 'menu': 'Rotis, Jeera Rice, Mixed Veg Sabzi, Rasam, Dessert'},
  ];

  // Emergency Contacts
  static const List<Map<String, String>> emergencyContacts = [
    {'name': 'Chief Hostel Warden', 'role': 'Dr. K. S. Raman', 'phone': '+91 98450 11223'},
    {'name': 'Deputy Warden (Boys)', 'role': 'Prof. A. Verma', 'phone': '+91 98450 33445'},
    {'name': 'Deputy Warden (Girls)', 'role': 'Dr. S. Nair', 'phone': '+91 98450 55667'},
    {'name': 'Campus Health Center', 'role': '24/7 Ambulance & Doctor', 'phone': '+91 98450 99999'},
    {'name': 'Hostel Security Desk', 'role': 'Main Gate Control', 'phone': '+91 98450 77889'},
    {'name': 'Hostel Maintenance Supervisor', 'role': 'Electrical & Plumbing', 'phone': '+91 98450 44556'},
  ];
}
