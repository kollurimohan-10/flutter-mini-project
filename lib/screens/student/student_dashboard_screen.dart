import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/mongo_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_drawer.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _mongo = MongoService();
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  int _navIndex = 0;

  void _refresh() {
    AuthService().refreshCurrentStudent();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final student = AuthService().currentStudent;
    final notices = _mongo.getAnnouncements().take(2).toList();
    final studentId = student?.id ?? 'STU1001';

    final totalPaid = _mongo.getTotalPaidForStudent(studentId);
    final due = _mongo.getDueAmountForStudent(studentId);
    final feeStatus = _mongo.getPaymentStatusForStudent(studentId);
    final attPercent = _mongo.calculateAttendancePercentage(studentId);
    final myComplaints = _mongo.getComplaintsForStudent(studentId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            tooltip: 'My Profile',
            onPressed: () => Navigator.pushNamed(context, '/student_profile').then((_) => _refresh()),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        student?.initials ?? 'ST',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryNavy),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student?.name ?? 'Rahul Sharma',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${student?.course ?? "B.Tech"} • Year ${student?.year ?? "3rd"}',
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              student?.isAllocated == true ? 'Room: ${student!.roomNumber}' : 'Unallocated',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Overview Metric Grid
              const Text(
                'My Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'My Room',
                    value: student?.roomNumber ?? 'None',
                    icon: Icons.hotel_rounded,
                    color: AppTheme.primaryBlue,
                    subtitle: 'Tap to view roommates',
                    onTap: () => Navigator.pushNamed(context, '/student_room'),
                  ),
                  StatCard(
                    title: 'Attendance',
                    value: '${attPercent.toStringAsFixed(0)}%',
                    icon: Icons.fact_check_rounded,
                    color: attPercent >= 75 ? AppTheme.statusSuccess : AppTheme.statusDanger,
                    subtitle: 'Attendance history',
                    onTap: () => Navigator.pushNamed(context, '/student_attendance'),
                  ),
                  StatCard(
                    title: 'Pending Fee Due',
                    value: _currency.format(due),
                    icon: Icons.payments_rounded,
                    color: due > 0 ? AppTheme.statusWarning : AppTheme.statusSuccess,
                    subtitle: feeStatus,
                    onTap: () => Navigator.pushNamed(context, '/student_fees'),
                  ),
                  StatCard(
                    title: 'My Complaints',
                    value: '${myComplaints.length}',
                    icon: Icons.report_problem_rounded,
                    color: AppTheme.accentTeal,
                    subtitle: '${myComplaints.where((c) => c.status != "Resolved").length} unresolved',
                    onTap: () => Navigator.pushNamed(context, '/student_complaints'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _actionButton(
                    icon: Icons.build_circle_rounded,
                    label: 'File Complaint',
                    color: Colors.deepOrange,
                    onTap: () => Navigator.pushNamed(context, '/student_complaints').then((_) => _refresh()),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    icon: Icons.flight_takeoff_rounded,
                    label: 'Apply Leave',
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(context, '/student_leaves').then((_) => _refresh()),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Mess & Rules',
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(context, '/hostel_info'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Latest Notices
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Latest Hostel Notices',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/student_announcements'),
                    child: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (notices.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No notices available.')))
              else
                ...notices.map((n) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: n.isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
                      child: Icon(Icons.campaign_rounded, color: n.isUrgent ? AppTheme.statusDanger : AppTheme.primaryBlue, size: 20),
                    ),
                    title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: Text('${n.date} • ${n.author}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5)),
                    trailing: StatusBadge(status: n.priority, fontSize: 10),
                    onTap: () => Navigator.pushNamed(context, '/student_announcements'),
                  ),
                )),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _navIndex = index);
          if (index == 1) {
            Navigator.pushNamed(context, '/student_room').then((_) => _refresh());
          } else if (index == 2) {
            Navigator.pushNamed(context, '/student_fees').then((_) => _refresh());
          } else if (index == 3) {
            Navigator.pushNamed(context, '/student_profile').then((_) => _refresh());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel_rounded), label: 'My Room'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_rounded), label: 'Fees'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
