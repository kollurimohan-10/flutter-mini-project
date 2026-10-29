import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'models/student_model.dart';
import 'models/room_model.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

// Admin screens
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/student_list_screen.dart';
import 'screens/admin/student_form_screen.dart';
import 'screens/admin/student_details_screen.dart';
import 'screens/admin/room_list_screen.dart';
import 'screens/admin/room_form_screen.dart';
import 'screens/admin/room_details_screen.dart';
import 'screens/admin/attendance_screen.dart';
import 'screens/admin/fee_management_screen.dart';
import 'screens/admin/admin_complaints_screen.dart';
import 'screens/admin/admin_leaves_screen.dart';
import 'screens/admin/admin_announcements_screen.dart';
import 'screens/admin/reports_screen.dart';

// Student screens
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/student_profile_screen.dart';
import 'screens/student/student_room_screen.dart';
import 'screens/student/student_fees_screen.dart';
import 'screens/student/student_attendance_screen.dart';
import 'screens/student/student_complaints_screen.dart';
import 'screens/student/student_leaves_screen.dart';
import 'screens/student/student_announcements_screen.dart';

// Common screens
import 'screens/common/hostel_info_screen.dart';
import 'screens/common/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HostelManagementApp());
}

class HostelManagementApp extends StatelessWidget {
  const HostelManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/student_dashboard': (context) => const StudentDashboardScreen(),
        '/student_list': (context) => const StudentListScreen(),
        '/room_list': (context) => const RoomListScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/fee_management': (context) => const FeeManagementScreen(),
        '/admin_complaints': (context) => const AdminComplaintsScreen(),
        '/admin_leaves': (context) => const AdminLeavesScreen(),
        '/admin_announcements': (context) => const AdminAnnouncementsScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/student_profile': (context) => const StudentProfileScreen(),
        '/student_room': (context) => const StudentRoomScreen(),
        '/student_fees': (context) => const StudentFeesScreen(),
        '/student_attendance': (context) => const StudentAttendanceScreen(),
        '/student_complaints': (context) => const StudentComplaintsScreen(),
        '/student_leaves': (context) => const StudentLeavesScreen(),
        '/student_announcements': (context) => const StudentAnnouncementsScreen(),
        '/hostel_info': (context) => const HostelInfoScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/student_details') {
          final studentId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => StudentDetailsScreen(studentId: studentId),
          );
        }
        if (settings.name == '/student_form') {
          final studentToEdit = settings.arguments as StudentModel?;
          return MaterialPageRoute(
            builder: (context) => StudentFormScreen(studentToEdit: studentToEdit),
          );
        }
        if (settings.name == '/room_details') {
          final roomId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(roomId: roomId),
          );
        }
        if (settings.name == '/room_form') {
          final roomToEdit = settings.arguments as RoomModel?;
          return MaterialPageRoute(
            builder: (context) => RoomFormScreen(roomToEdit: roomToEdit),
          );
        }
        return null;
      },
    );
  }
}
