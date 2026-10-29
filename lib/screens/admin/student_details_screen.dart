import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mongo_service.dart';
import '../../models/student_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailsScreen({super.key, required this.studentId});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final _mongo = MongoService();
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  StudentModel? _student;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  void _loadStudent() {
    setState(() {
      _student = _mongo.getStudentById(widget.studentId);
    });
  }

  void _confirmDelete() async {
    if (_student == null) return;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Student',
      message: 'Are you sure you want to permanently delete ${_student!.name}? This will free up their bed in room ${_student!.roomNumber ?? "N/A"}.',
      confirmText: 'Delete Record',
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed) {
      await _mongo.deleteStudent(_student!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_student!.name} deleted'), backgroundColor: AppTheme.statusDanger),
        );
        Navigator.pop(context, true);
      }
    }
  }

  void _vacateRoom() async {
    if (_student == null || !_student!.isAllocated) return;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Vacate Room',
      message: 'Do you want to de-allocate room ${_student!.roomNumber} for ${_student!.name}?',
      confirmText: 'Vacate Bed',
      confirmColor: Colors.orange.shade800,
    );

    if (confirmed) {
      await _mongo.vacateStudent(_student!.id);
      _loadStudent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room vacated successfully'), backgroundColor: AppTheme.statusSuccess),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Details')),
        body: const Center(child: Text('Student record not found')),
      );
    }

    final s = _student!;
    final totalPaid = _mongo.getTotalPaidForStudent(s.id);
    final due = _mongo.getDueAmountForStudent(s.id);
    final feeStatus = _mongo.getPaymentStatusForStudent(s.id);
    final attPercent = _mongo.calculateAttendancePercentage(s.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Details',
            onPressed: () {
              Navigator.pushNamed(context, '/student_form', arguments: s).then((_) => _loadStudent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Record',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: s.gender == 'Female' ? Colors.pink.shade50 : Colors.blue.shade50,
                      child: Text(
                        s.initials,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: s.gender == 'Female' ? Colors.pink.shade700 : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${s.id}  •  Roll: ${s.rollNo}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              StatusBadge(status: s.isAllocated ? 'Room ${s.roomNumber}' : 'Unallocated'),
                              const SizedBox(width: 8),
                              StatusBadge(status: '$attPercent% Attendance'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Fee Summary Quick Card
            Card(
              color: Colors.blueGrey.shade50.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hostel Fee Summary',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        StatusBadge(status: feeStatus),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _feeItem('Total Fee', _currency.format(s.feeAmount), Colors.grey.shade800),
                        _feeItem('Paid Amount', _currency.format(totalPaid), AppTheme.statusSuccess),
                        _feeItem('Outstanding Due', _currency.format(due), due > 0 ? AppTheme.statusDanger : Colors.grey.shade700),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.payment_rounded, size: 16),
                        label: const Text('Record Fee Payment'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/fee_management').then((_) => _loadStudent());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Room & Allocation Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Room Allocation',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                        ),
                        if (s.isAllocated)
                          TextButton(
                            onPressed: _vacateRoom,
                            style: TextButton.styleFrom(foregroundColor: AppTheme.statusDanger),
                            child: const Text('Vacate Room', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _detailRow(Icons.hotel_rounded, 'Allocated Room', s.isAllocated ? 'Room ${s.roomNumber}' : 'Not yet allocated'),
                    _detailRow(Icons.calendar_today_rounded, 'Admission Date', s.admissionDate),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Academic & Contact Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Academic & Personal Info',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 8),
                    _detailRow(Icons.school_rounded, 'College', s.college),
                    _detailRow(Icons.menu_book_rounded, 'Course', '${s.course} (${s.year})'),
                    _detailRow(Icons.cake_rounded, 'Date of Birth', s.dob),
                    _detailRow(Icons.transgender_rounded, 'Gender', s.gender),
                    _detailRow(Icons.phone_rounded, 'Phone Number', s.phone),
                    _detailRow(Icons.email_rounded, 'Email Address', s.email),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Guardian Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guardian & Emergency Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 8),
                    _detailRow(Icons.family_restroom_rounded, 'Parent Name', s.parentName),
                    _detailRow(Icons.phone_android_rounded, 'Parent Phone', s.parentPhone),
                    _detailRow(Icons.emergency_rounded, 'Emergency Contact', s.emergencyContact),
                    _detailRow(Icons.home_rounded, 'Permanent Address', s.address),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _feeItem(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valColor)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}
