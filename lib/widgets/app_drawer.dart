import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/confirm_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    final isAdmin = auth.isAdmin;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryNavy, AppTheme.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              user?.name ?? (isAdmin ? 'Admin / Warden' : 'Hostel Resident'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.email ?? (isAdmin ? 'warden@nit.edu' : 'student@nit.edu'),
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAdmin ? AppTheme.accentTeal : Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isAdmin ? 'ADMINISTRATOR' : 'STUDENT',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                isAdmin ? 'AD' : (user?.name?.substring(0, 1) ?? 'ST'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (isAdmin) ...[
                  _drawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Admin Dashboard',
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin_dashboard'),
                  ),
                  _drawerItem(
                    icon: Icons.people_alt_rounded,
                    title: 'Student Directory',
                    onTap: () => Navigator.pushNamed(context, '/student_list'),
                  ),
                  _drawerItem(
                    icon: Icons.meeting_room_rounded,
                    title: 'Room Management',
                    onTap: () => Navigator.pushNamed(context, '/room_list'),
                  ),
                  _drawerItem(
                    icon: Icons.fact_check_rounded,
                    title: 'Daily Attendance',
                    onTap: () => Navigator.pushNamed(context, '/attendance'),
                  ),
                  _drawerItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Fee Management',
                    onTap: () => Navigator.pushNamed(context, '/fee_management'),
                  ),
                  _drawerItem(
                    icon: Icons.report_problem_rounded,
                    title: 'Complaints Desk',
                    onTap: () => Navigator.pushNamed(context, '/admin_complaints'),
                  ),
                  _drawerItem(
                    icon: Icons.time_to_leave_rounded,
                    title: 'Leave Requests',
                    onTap: () => Navigator.pushNamed(context, '/admin_leaves'),
                  ),
                  _drawerItem(
                    icon: Icons.campaign_rounded,
                    title: 'Announcements',
                    onTap: () => Navigator.pushNamed(context, '/admin_announcements'),
                  ),
                  _drawerItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Analytics & Reports',
                    onTap: () => Navigator.pushNamed(context, '/reports'),
                  ),
                ] else ...[
                  _drawerItem(
                    icon: Icons.home_rounded,
                    title: 'Student Dashboard',
                    onTap: () => Navigator.pushReplacementNamed(context, '/student_dashboard'),
                  ),
                  _drawerItem(
                    icon: Icons.person_rounded,
                    title: 'My Profile',
                    onTap: () => Navigator.pushNamed(context, '/student_profile'),
                  ),
                  _drawerItem(
                    icon: Icons.hotel_rounded,
                    title: 'My Room & Roommates',
                    onTap: () => Navigator.pushNamed(context, '/student_room'),
                  ),
                  _drawerItem(
                    icon: Icons.payments_rounded,
                    title: 'Fee Status & Receipts',
                    onTap: () => Navigator.pushNamed(context, '/student_fees'),
                  ),
                  _drawerItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Attendance Record',
                    onTap: () => Navigator.pushNamed(context, '/student_attendance'),
                  ),
                  _drawerItem(
                    icon: Icons.support_agent_rounded,
                    title: 'My Complaints',
                    onTap: () => Navigator.pushNamed(context, '/student_complaints'),
                  ),
                  _drawerItem(
                    icon: Icons.flight_takeoff_rounded,
                    title: 'Apply for Leave',
                    onTap: () => Navigator.pushNamed(context, '/student_leaves'),
                  ),
                  _drawerItem(
                    icon: Icons.notifications_active_rounded,
                    title: 'Hostel Notices',
                    onTap: () => Navigator.pushNamed(context, '/student_announcements'),
                  ),
                ],
                const Divider(),
                _drawerItem(
                  icon: Icons.menu_book_rounded,
                  title: 'Hostel Rules & Contacts',
                  onTap: () => Navigator.pushNamed(context, '/hostel_info'),
                ),
                _drawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings & MongoDB',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppTheme.statusDanger),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.statusDanger, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              final confirm = await ConfirmDialog.show(
                context: context,
                title: 'Sign Out',
                message: 'Are you sure you want to sign out of the system?',
                confirmText: 'Sign Out',
                icon: Icons.logout_rounded,
              );
              if (confirm && context.mounted) {
                auth.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppTheme.primaryNavy),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      dense: true,
      onTap: onTap,
    );
  }
}
