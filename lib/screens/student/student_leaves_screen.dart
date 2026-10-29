import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/mongo_service.dart';
import '../../models/leave_request_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class StudentLeavesScreen extends StatefulWidget {
  const StudentLeavesScreen({super.key});

  @override
  State<StudentLeavesScreen> createState() => _StudentLeavesScreenState();
}

class _StudentLeavesScreenState extends State<StudentLeavesScreen> {
  final _mongo = MongoService();

  void _showApplyLeaveModal() {
    final student = AuthService().currentStudent;
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    final parentPhoneController = TextEditingController(text: student?.parentPhone ?? '');

    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime returnDate = DateTime.now().add(const Duration(days: 4));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Apply for Hostel Outstation Leave',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5, color: AppTheme.primaryNavy),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Date pickers row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  startDate = picked;
                                  if (returnDate.isBefore(startDate)) {
                                    returnDate = startDate.add(const Duration(days: 1));
                                  }
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Departure Date', suffixIcon: Icon(Icons.calendar_today, size: 16)),
                              child: Text(DateFormat('yyyy-MM-dd').format(startDate), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: returnDate.isAfter(startDate) ? returnDate : startDate,
                                firstDate: startDate,
                                lastDate: DateTime.now().add(const Duration(days: 120)),
                              );
                              if (picked != null) {
                                setModalState(() => returnDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Expected Return', suffixIcon: Icon(Icons.event_repeat, size: 16)),
                              child: Text(DateFormat('yyyy-MM-dd').format(returnDate), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: parentPhoneController,
                      label: 'Parent / Guardian Contact',
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                    CustomTextField(
                      controller: reasonController,
                      label: 'Reason for Outstation Leave',
                      hint: 'e.g. Attending family function, medical treatment, festive break',
                      maxLines: 3,
                      validator: (v) => Validators.requiredField(v, 'Reason'),
                    ),

                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Submit Leave Application',
                      icon: Icons.send_rounded,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        // Validation: Return date must not be before start date
                        if (returnDate.isBefore(startDate)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error: Expected return date cannot be before departure date!'), backgroundColor: AppTheme.statusDanger),
                          );
                          return;
                        }

                        final leave = LeaveRequestModel(
                          id: 'LEV_${DateTime.now().millisecondsSinceEpoch}',
                          studentId: student?.id ?? 'STU1001',
                          studentName: student?.name ?? 'Rahul Sharma',
                          startDate: DateFormat('yyyy-MM-dd').format(startDate),
                          returnDate: DateFormat('yyyy-MM-dd').format(returnDate),
                          reason: reasonController.text.trim(),
                          parentContact: parentPhoneController.text.trim(),
                          status: AppConstants.leavePending,
                          appliedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        );

                        await _mongo.addLeaveRequest(leave);
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Leave application submitted to Chief Warden!'), backgroundColor: AppTheme.statusSuccess),
                          );
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = AuthService().currentStudent;
    final studentId = student?.id ?? 'STU1001';
    final leaves = _mongo.getLeavesForStudent(studentId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leave Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Apply for Leave',
            onPressed: _showApplyLeaveModal,
          ),
        ],
      ),
      body: leaves.isEmpty
          ? EmptyStateView(
              icon: Icons.flight_takeoff_outlined,
              title: 'No Leave Applications',
              message: 'You have not submitted any outstation leave requests.',
              actionText: 'Apply for Leave',
              onAction: _showApplyLeaveModal,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                final l = leaves[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l.startDate}  to  ${l.returnDate}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.primaryNavy),
                            ),
                            StatusBadge(status: l.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.reason,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Applied on: ${l.appliedDate}',
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                            ),
                            Text(
                              'Parent: ${l.parentContact}',
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        if (l.decisionNotes != null && l.decisionNotes!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: l.isApproved ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Warden Remark: ${l.decisionNotes}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: l.isApproved ? Colors.green.shade900 : Colors.red.shade900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Apply Leave'),
        onPressed: _showApplyLeaveModal,
      ),
    );
  }
}
