import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/mongo_service.dart';
import '../../models/complaint_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class StudentComplaintsScreen extends StatefulWidget {
  const StudentComplaintsScreen({super.key});

  @override
  State<StudentComplaintsScreen> createState() => _StudentComplaintsScreenState();
}

class _StudentComplaintsScreenState extends State<StudentComplaintsScreen> {
  final _mongo = MongoService();

  void _showNewComplaintModal() {
    final student = AuthService().currentStudent;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String category = AppConstants.complaintCategories.first;
    String priority = 'Medium';

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
                          'Submit Maintenance Request',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryNavy),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: titleController,
                      label: 'Complaint Title',
                      hint: 'e.g. Geyser not working, Fan regulator loose',
                      validator: (v) => Validators.requiredField(v, 'Title'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: category,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: AppConstants.complaintCategories
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12.5))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => category = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: priority,
                            decoration: const InputDecoration(labelText: 'Priority'),
                            items: ['Low', 'Medium', 'High']
                                .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => priority = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: descriptionController,
                      label: 'Detailed Description',
                      hint: 'Describe the issue clearly for the maintenance team...',
                      maxLines: 3,
                      validator: (v) => Validators.requiredField(v, 'Description'),
                    ),
                    const SizedBox(height: 18),
                    CustomButton(
                      text: 'Submit Grievance',
                      icon: Icons.send_rounded,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final complaint = ComplaintModel(
                          id: 'CMP_${DateTime.now().millisecondsSinceEpoch}',
                          studentId: student?.id ?? 'STU1001',
                          studentName: student?.name ?? 'Rahul Sharma',
                          roomNumber: student?.roomNumber ?? 'A-101',
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          category: category,
                          priority: priority,
                          status: AppConstants.complaintPending,
                          submissionDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        );

                        await _mongo.addComplaint(complaint);
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Complaint submitted successfully!'), backgroundColor: AppTheme.statusSuccess),
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
    final complaints = _mongo.getComplaintsForStudent(studentId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints & Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New Complaint',
            onPressed: _showNewComplaintModal,
          ),
        ],
      ),
      body: complaints.isEmpty
          ? EmptyStateView(
              icon: Icons.assignment_turned_in_outlined,
              title: 'No Active Complaints',
              message: 'You have not submitted any complaints yet. Everything looks good!',
              actionText: 'Report an Issue',
              onAction: _showNewComplaintModal,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final c = complaints[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBadge(status: c.category),
                            StatusBadge(status: c.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.description,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Submitted on: ${c.submissionDate}',
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                            ),
                            StatusBadge(status: '${c.priority} Priority', fontSize: 10),
                          ],
                        ),
                        if (c.resolutionNotes != null && c.resolutionNotes!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.statusSuccess),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Resolution: ${c.resolutionNotes}',
                                    style: TextStyle(fontSize: 12, color: Colors.green.shade900, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
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
        label: const Text('New Complaint'),
        onPressed: _showNewComplaintModal,
      ),
    );
  }
}
