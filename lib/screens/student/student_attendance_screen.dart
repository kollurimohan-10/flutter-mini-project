import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/mongo_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = AuthService().currentStudent;
    final mongo = MongoService();
    final studentId = student?.id ?? 'STU1001';

    final records = mongo.getStudentAttendance(studentId);
    final percentage = mongo.calculateAttendancePercentage(studentId);
    final presentCount = records.where((r) => r.status == 'Present').length;
    final absentCount = records.where((r) => r.status == 'Absent').length;
    final leaveCount = records.where((r) => r.status == 'On Leave').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance History'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendance Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: (percentage / 100).clamp(0.0, 1.0),
                                strokeWidth: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  percentage >= 75 ? AppTheme.statusSuccess : AppTheme.statusDanger,
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${percentage.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Overall Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(
                                percentage >= 75
                                    ? 'Good standing (Eligible for exams)'
                                    : 'Low attendance alert (< 75% required)',
                                style: TextStyle(
                                  color: percentage >= 75 ? AppTheme.statusSuccess : AppTheme.statusDanger,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _counter('Present', '$presentCount', AppTheme.statusSuccess),
                        _counter('Absent', '$absentCount', AppTheme.statusDanger),
                        _counter('On Leave', '$leaveCount', AppTheme.statusInfo),
                        _counter('Total Marked', '${records.length}', Colors.grey.shade800),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Daily Attendance Logs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: 8),

            if (records.isEmpty)
              const EmptyStateView(
                icon: Icons.calendar_today_outlined,
                title: 'No Records Found',
                message: 'No daily attendance marked for your ID yet.',
              )
            else
              ...records.map((r) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: r.isPresent
                        ? Colors.green.shade50
                        : (r.isAbsent ? Colors.red.shade50 : Colors.blue.shade50),
                    child: Icon(
                      r.isPresent
                          ? Icons.check_circle_outline
                          : (r.isAbsent ? Icons.cancel_outlined : Icons.flight_takeoff_rounded),
                      color: r.isPresent
                          ? AppTheme.statusSuccess
                          : (r.isAbsent ? AppTheme.statusDanger : AppTheme.statusInfo),
                      size: 22,
                    ),
                  ),
                  title: Text(r.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(r.remarks ?? (r.isPresent ? 'Attended roll call' : 'Hostel absence record'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  trailing: StatusBadge(status: r.status),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _counter(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
