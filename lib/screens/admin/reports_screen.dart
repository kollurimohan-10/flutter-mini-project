import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mongo_service.dart';
import '../../utils/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mongo = MongoService();
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    // Calculated metrics
    final totalStudents = mongo.totalStudents;
    final totalRooms = mongo.totalRooms;
    final occupiedRooms = mongo.occupiedRooms;
    final totalBeds = mongo.totalBeds;
    final occupiedBeds = mongo.occupiedBeds;
    final availableBeds = mongo.availableBeds;
    final bedOccupancyRate = totalBeds > 0 ? (occupiedBeds / totalBeds) * 100 : 0.0;

    final expectedFees = mongo.totalExpectedFees;
    final collectedFees = mongo.totalCollectedFees;
    final pendingFees = mongo.totalPendingFees;
    final feeCollectionRate = expectedFees > 0 ? (collectedFees / expectedFees) * 100 : 0.0;

    final totalComplaints = mongo.getComplaints().length;
    final resolvedComplaints = mongo.getComplaints().where((c) => c.status == 'Resolved').length;
    final complaintResolutionRate = totalComplaints > 0 ? (resolvedComplaints / totalComplaints) * 100 : 0.0;

    final totalLeaves = mongo.getLeaveRequests().length;
    final approvedLeaves = mongo.getLeaveRequests().where((l) => l.status == 'Approved').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Analytics & Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics_rounded, size: 40, color: AppTheme.accentTeal),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hostel Administration Report',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aggregated live statistics from MongoDB records',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Section 1: Room Occupancy & Capacity
            _reportCard(
              title: 'Room & Bed Occupancy',
              icon: Icons.meeting_room_rounded,
              color: AppTheme.primaryBlue,
              children: [
                _progressMetric(
                  label: 'Bed Capacity Utilization',
                  percent: bedOccupancyRate,
                  valueText: '$occupiedBeds / $totalBeds Beds (${bedOccupancyRate.toStringAsFixed(1)}%)',
                  color: bedOccupancyRate > 85 ? AppTheme.statusDanger : AppTheme.primaryBlue,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _smallStat('Total Rooms', '$totalRooms'),
                    _smallStat('Occupied Rooms', '$occupiedRooms'),
                    _smallStat('Available Beds', '$availableBeds'),
                    _smallStat('Students Housed', '$totalStudents'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 2: Fee Collections vs Dues
            _reportCard(
              title: 'Hostel Revenue & Outstanding Dues',
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.teal,
              children: [
                _progressMetric(
                  label: 'Fee Collection Efficiency',
                  percent: feeCollectionRate,
                  valueText: '${feeCollectionRate.toStringAsFixed(1)}% Collected',
                  color: AppTheme.statusSuccess,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _smallStat('Total Billed', currency.format(expectedFees)),
                    _smallStat('Collected', currency.format(collectedFees)),
                    _smallStat('Pending Dues', currency.format(pendingFees), AppTheme.statusDanger),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 3: Grievance & Maintenance Resolution
            _reportCard(
              title: 'Complaints Resolution Rate',
              icon: Icons.build_circle_rounded,
              color: Colors.deepOrange,
              children: [
                _progressMetric(
                  label: 'Grievance Resolution',
                  percent: complaintResolutionRate,
                  valueText: '$resolvedComplaints of $totalComplaints Solved (${complaintResolutionRate.toStringAsFixed(1)}%)',
                  color: complaintResolutionRate >= 75 ? AppTheme.statusSuccess : Colors.orange,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _smallStat('Total Filed', '$totalComplaints'),
                    _smallStat('Resolved', '$resolvedComplaints', AppTheme.statusSuccess),
                    _smallStat('Pending', '${mongo.pendingComplaintsCount}', AppTheme.statusDanger),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 4: Leave Requests Summary
            _reportCard(
              title: 'Leave & Movement Tracking',
              icon: Icons.time_to_leave_rounded,
              color: Colors.purple,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _smallStat('Total Applications', '$totalLeaves'),
                    _smallStat('Approved Leaves', '$approvedLeaves', AppTheme.statusSuccess),
                    _smallStat('Pending Action', '${mongo.pendingLeavesCount}', Colors.orange),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _progressMetric({
    required String label,
    required double percent,
    required String valueText,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(valueText, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _smallStat(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
            color: color ?? AppTheme.primaryNavy,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
