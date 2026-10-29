import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mongo_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _mongo = MongoService();
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  int _bottomNavIndex = 0;

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final complaints = _mongo.getComplaints().take(3).toList();
    final leaves = _mongo.getLeaveRequests().take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & MongoDB',
            onPressed: () => Navigator.pushNamed(context, '/settings').then((_) => _refresh()),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryNavy, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.name ?? "Hostel Warden"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hostel Administration & Resident Management',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _mongo.isConnected ? AppTheme.statusSuccess : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _mongo.isConnected ? 'MongoDB Connected' : 'Local Offline Mode',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppTheme.accentTeal, size: 36),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Statistics Grid
              const Text(
                'Hostel Overview',
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
                    title: 'Total Students',
                    value: '${_mongo.totalStudents}',
                    icon: Icons.people_alt_rounded,
                    color: AppTheme.primaryBlue,
                    onTap: () => Navigator.pushNamed(context, '/student_list').then((_) => _refresh()),
                  ),
                  StatCard(
                    title: 'Rooms / Occupied',
                    value: '${_mongo.occupiedRooms} / ${_mongo.totalRooms}',
                    icon: Icons.meeting_room_rounded,
                    color: AppTheme.accentTeal,
                    subtitle: '${_mongo.availableBeds} beds available',
                    onTap: () => Navigator.pushNamed(context, '/room_list').then((_) => _refresh()),
                  ),
                  StatCard(
                    title: 'Pending Dues',
                    value: _currency.format(_mongo.totalPendingFees),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.statusWarning,
                    subtitle: 'Collected: ${_currency.format(_mongo.totalCollectedFees)}',
                    onTap: () => Navigator.pushNamed(context, '/fee_management').then((_) => _refresh()),
                  ),
                  StatCard(
                    title: 'Active Complaints',
                    value: '${_mongo.pendingComplaintsCount}',
                    icon: Icons.report_problem_rounded,
                    color: _mongo.pendingComplaintsCount > 0 ? AppTheme.statusDanger : AppTheme.statusSuccess,
                    subtitle: '${_mongo.pendingLeavesCount} leave requests pending',
                    onTap: () => Navigator.pushNamed(context, '/admin_complaints').then((_) => _refresh()),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _actionChip(
                      icon: Icons.person_add_rounded,
                      label: 'New Student',
                      color: AppTheme.primaryBlue,
                      onTap: () => Navigator.pushNamed(context, '/student_form').then((_) => _refresh()),
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: Icons.add_home_rounded,
                      label: 'Add Room',
                      color: AppTheme.accentTeal,
                      onTap: () => Navigator.pushNamed(context, '/room_form').then((_) => _refresh()),
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: Icons.fact_check_rounded,
                      label: 'Mark Attendance',
                      color: Colors.indigo,
                      onTap: () => Navigator.pushNamed(context, '/attendance').then((_) => _refresh()),
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: Icons.payment_rounded,
                      label: 'Collect Fee',
                      color: Colors.teal,
                      onTap: () => Navigator.pushNamed(context, '/fee_management').then((_) => _refresh()),
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: Icons.campaign_rounded,
                      label: 'Broadcast Notice',
                      color: Colors.deepOrange,
                      onTap: () => Navigator.pushNamed(context, '/admin_announcements').then((_) => _refresh()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Complaints Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Complaints',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/admin_complaints').then((_) => _refresh()),
                    child: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (complaints.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No complaints filed yet.')),
                  ),
                )
              else
                ...complaints.map((c) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade50,
                      child: Icon(Icons.build_rounded, size: 20, color: Colors.blueGrey.shade700),
                    ),
                    title: Text(
                      c.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${c.studentName} (${c.roomNumber}) • ${c.category}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    trailing: StatusBadge(status: c.status),
                    onTap: () => Navigator.pushNamed(context, '/admin_complaints').then((_) => _refresh()),
                  ),
                )),

              const SizedBox(height: 20),

              // Recent Leave Requests Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Leave Applications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/admin_leaves').then((_) => _refresh()),
                    child: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (leaves.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No leave applications submitted.')),
                  ),
                )
              else
                ...leaves.map((l) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade50,
                      child: Icon(Icons.flight_takeoff_rounded, size: 20, color: Colors.purple.shade700),
                    ),
                    title: Text(
                      l.studentName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${l.startDate} to ${l.returnDate} • ${l.reason}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    trailing: StatusBadge(status: l.status),
                    onTap: () => Navigator.pushNamed(context, '/admin_leaves').then((_) => _refresh()),
                  ),
                )),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 1) {
            Navigator.pushNamed(context, '/student_list').then((_) => _refresh());
          } else if (index == 2) {
            Navigator.pushNamed(context, '/room_list').then((_) => _refresh());
          } else if (index == 3) {
            Navigator.pushNamed(context, '/reports').then((_) => _refresh());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room_rounded), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
