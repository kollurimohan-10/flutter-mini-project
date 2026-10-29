import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/mongo_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _mongo = MongoService();

  void _showEditContactModal() {
    final student = AuthService().currentStudent;
    if (student == null) return;

    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController(text: student.phone);
    final emailController = TextEditingController(text: student.email);
    final emergencyController = TextEditingController(text: student.emergencyContact);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
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
                      'Update Contact Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryNavy),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                CustomTextField(
                  controller: emailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                CustomTextField(
                  controller: emergencyController,
                  label: 'Emergency Contact Number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Save Changes',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final updated = student.copyWith(
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      emergencyContact: emergencyController.text.trim(),
                    );
                    await _mongo.updateStudent(updated);
                    AuthService().refreshCurrentStudent();

                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact details updated successfully'), backgroundColor: AppTheme.statusSuccess),
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
  }

  @override
  Widget build(BuildContext context) {
    final student = AuthService().currentStudent;
    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('Profile information not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: 'Edit Contact Info',
            onPressed: _showEditContactModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: student.gender == 'Female' ? Colors.pink.shade50 : Colors.blue.shade50,
                      child: Text(
                        student.initials,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: student.gender == 'Female' ? Colors.pink.shade700 : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${student.id}  •  Roll: ${student.rollNo}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit Contact Info', style: TextStyle(fontSize: 12)),
                      onPressed: _showEditContactModal,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Academic Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Academic Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 8),
                    _profileRow('College', student.college),
                    _profileRow('Department', student.course),
                    _profileRow('Current Year', student.year),
                    _profileRow('Admission Date', student.admissionDate),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Contact & Emergency
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact & Emergency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 8),
                    _profileRow('Phone Number', student.phone),
                    _profileRow('Email Address', student.email),
                    _profileRow('Emergency Contact', student.emergencyContact),
                    _profileRow('Parent Name', student.parentName),
                    _profileRow('Parent Phone', student.parentPhone),
                    _profileRow('Permanent Address', student.address),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Room Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hostel Accommodation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 8),
                    _profileRow('Room Number', student.roomNumber ?? 'Not Allocated'),
                    _profileRow('Hostel Fee', '₹${student.feeAmount.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              '* Note: Academic and Room allocations are managed by the hostel warden.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}
