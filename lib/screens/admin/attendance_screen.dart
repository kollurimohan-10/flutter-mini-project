import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mongo_service.dart';
import '../../models/student_model.dart';
import '../../models/attendance_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _mongo = MongoService();
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceMap = {}; // studentId -> status
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAttendanceForDate();
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _loadAttendanceForDate() {
    final existing = _mongo.getAttendanceByDate(_formattedDate);
    final students = _mongo.getStudents();

    setState(() {
      _attendanceMap.clear();
      for (final s in students) {
        final found = existing.firstWhere(
          (a) => a.studentId == s.id,
          orElse: () => AttendanceModel(id: '', studentId: s.id, studentName: s.name, date: _formattedDate, status: AppConstants.attPresent),
        );
        _attendanceMap[s.id] = found.status;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadAttendanceForDate();
    }
  }

  void _markAll(String status) {
    setState(() {
      for (final key in _attendanceMap.keys) {
        _attendanceMap[key] = status;
      }
    });
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);

    final students = _mongo.getStudents();
    final records = <AttendanceModel>[];

    for (final s in students) {
      final status = _attendanceMap[s.id] ?? AppConstants.attPresent;
      records.add(AttendanceModel(
        id: 'ATT_${_formattedDate}_${s.id}',
        studentId: s.id,
        studentName: s.name,
        date: _formattedDate,
        status: status,
      ));
    }

    await _mongo.saveAttendanceBatch(records);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance saved for ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
          backgroundColor: AppTheme.statusSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = _mongo.getStudents();
    final presentCount = _attendanceMap.values.where((v) => v == AppConstants.attPresent).length;
    final absentCount = _attendanceMap.values.where((v) => v == AppConstants.attAbsent).length;
    final leaveCount = _attendanceMap.values.where((v) => v == AppConstants.attLeave).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Select Date',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      child: Row(
                        children: [
                          const Icon(Icons.event_note_rounded, color: AppTheme.primaryBlue, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _pickDate,
                      child: const Text('Change Date', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Attendance Metrics Bar
                Row(
                  children: [
                    _statusCounter('Present', presentCount, AppTheme.statusSuccess),
                    const SizedBox(width: 8),
                    _statusCounter('Absent', absentCount, AppTheme.statusDanger),
                    const SizedBox(width: 8),
                    _statusCounter('On Leave', leaveCount, AppTheme.statusInfo),
                  ],
                ),
                const SizedBox(height: 10),

                // Batch quick mark
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Mark all as:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _markAll(AppConstants.attPresent),
                      child: const Text('Present', style: TextStyle(color: AppTheme.statusSuccess, fontWeight: FontWeight.bold, fontSize: 12.5)),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    InkWell(
                      onTap: () => _markAll(AppConstants.attAbsent),
                      child: const Text('Absent', style: TextStyle(color: AppTheme.statusDanger, fontWeight: FontWeight.bold, fontSize: 12.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Students Attendance List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                final currentStatus = _attendanceMap[s.id] ?? AppConstants.attPresent;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(s.initials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(
                                '${s.rollNo} • ${s.isAllocated ? "Room ${s.roomNumber}" : "No Room"}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        // 3-way status toggle
                        Row(
                          children: [
                            _toggleButton(
                              label: 'P',
                              tooltip: 'Present',
                              isSelected: currentStatus == AppConstants.attPresent,
                              color: AppTheme.statusSuccess,
                              onTap: () => setState(() => _attendanceMap[s.id] = AppConstants.attPresent),
                            ),
                            const SizedBox(width: 6),
                            _toggleButton(
                              label: 'A',
                              tooltip: 'Absent',
                              isSelected: currentStatus == AppConstants.attAbsent,
                              color: AppTheme.statusDanger,
                              onTap: () => setState(() => _attendanceMap[s.id] = AppConstants.attAbsent),
                            ),
                            const SizedBox(width: 6),
                            _toggleButton(
                              label: 'L',
                              tooltip: 'On Leave',
                              isSelected: currentStatus == AppConstants.attLeave,
                              color: AppTheme.statusInfo,
                              onTap: () => setState(() => _attendanceMap[s.id] = AppConstants.attLeave),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Save Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3)),
              ],
            ),
            child: CustomButton(
              text: 'Save Attendance Record',
              icon: Icons.check_circle_rounded,
              isLoading: _isSaving,
              onPressed: _saveAttendance,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCounter(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required String tooltip,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
