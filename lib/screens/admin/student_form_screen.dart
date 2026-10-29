import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import '../../models/student_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class StudentFormScreen extends StatefulWidget {
  final StudentModel? studentToEdit;

  const StudentFormScreen({super.key, this.studentToEdit});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mongo = MongoService();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _collegeController;
  late TextEditingController _courseController;
  late TextEditingController _yearController;
  late TextEditingController _rollNoController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _addressController;
  late TextEditingController _admissionDateController;
  late TextEditingController _feeAmountController;
  late TextEditingController _emergencyContactController;

  String _gender = 'Male';
  String? _selectedRoomNumber;
  bool _isLoading = false;

  bool get _isEditing => widget.studentToEdit != null;

  @override
  void initState() {
    super.initState();
    final s = widget.studentToEdit;

    _idController = TextEditingController(text: s?.id ?? 'STU${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    _nameController = TextEditingController(text: s?.name ?? '');
    _dobController = TextEditingController(text: s?.dob ?? '2004-05-15');
    _collegeController = TextEditingController(text: s?.college ?? 'National Institute of Technology');
    _courseController = TextEditingController(text: s?.course ?? 'B.Tech Computer Science');
    _yearController = TextEditingController(text: s?.year ?? '1st Year');
    _rollNoController = TextEditingController(text: s?.rollNo ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _parentNameController = TextEditingController(text: s?.parentName ?? '');
    _parentPhoneController = TextEditingController(text: s?.parentPhone ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _admissionDateController = TextEditingController(text: s?.admissionDate ?? '2026-08-01');
    _feeAmountController = TextEditingController(text: s != null ? s.feeAmount.toStringAsFixed(0) : '35000');
    _emergencyContactController = TextEditingController(text: s?.emergencyContact ?? '');

    _gender = s?.gender ?? 'Male';
    _selectedRoomNumber = s?.roomNumber;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    _rollNoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    _admissionDateController.dispose();
    _feeAmountController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _idController.text.trim();
    final rollNo = _rollNoController.text.trim();

    // Prevent duplicate student IDs
    if (_mongo.isStudentIdTaken(id, widget.studentToEdit?.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Student ID is already registered to another student!'), backgroundColor: AppTheme.statusDanger),
      );
      return;
    }

    // Prevent duplicate roll numbers
    if (_mongo.isRollNoTaken(rollNo, widget.studentToEdit?.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Roll number is already registered!'), backgroundColor: AppTheme.statusDanger),
      );
      return;
    }

    // Prevent over-allocation if allocating a room
    if (_selectedRoomNumber != null && _selectedRoomNumber!.isNotEmpty) {
      final room = _mongo.getRoomByNumber(_selectedRoomNumber!);
      final occupants = _mongo.getStudentsInRoom(_selectedRoomNumber!);
      final isAlreadyInRoom = widget.studentToEdit?.roomNumber == _selectedRoomNumber;
      if (room != null && !isAlreadyInRoom && occupants.length >= room.totalBeds) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room $_selectedRoomNumber is full (${room.totalBeds} beds). Select another room.'), backgroundColor: AppTheme.statusDanger),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final student = StudentModel(
      id: id,
      name: _nameController.text.trim(),
      gender: _gender,
      dob: _dobController.text.trim(),
      college: _collegeController.text.trim(),
      course: _courseController.text.trim(),
      year: _yearController.text.trim(),
      rollNo: rollNo,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      parentName: _parentNameController.text.trim(),
      parentPhone: _parentPhoneController.text.trim(),
      address: _addressController.text.trim(),
      admissionDate: _admissionDateController.text.trim(),
      roomNumber: _selectedRoomNumber,
      feeAmount: double.tryParse(_feeAmountController.text.trim()) ?? 30000.0,
      emergencyContact: _emergencyContactController.text.trim().isNotEmpty
          ? _emergencyContactController.text.trim()
          : _parentPhoneController.text.trim(),
    );

    if (_isEditing) {
      await _mongo.updateStudent(student);
    } else {
      await _mongo.addStudent(student);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Student updated successfully' : 'Student added successfully'),
          backgroundColor: AppTheme.statusSuccess,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rooms available for allocation
    final rooms = _mongo.getRooms();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Student Details' : 'Register New Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Basic & Academic Information', Icons.school_rounded),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _idController,
                      label: 'Student ID',
                      readOnly: _isEditing,
                      validator: (v) => Validators.requiredField(v, 'Student ID'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _rollNoController,
                      label: 'Roll Number',
                      validator: (v) => Validators.requiredField(v, 'Roll Number'),
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_rounded,
                validator: (v) => Validators.requiredField(v, 'Full Name'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (val) => setState(() => _gender = val ?? 'Male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _dobController,
                      label: 'Date of Birth (YYYY-MM-DD)',
                      validator: (v) => Validators.requiredField(v, 'DOB'),
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _collegeController,
                label: 'College / Institute',
                validator: (v) => Validators.requiredField(v, 'College'),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _courseController,
                      label: 'Course & Branch',
                      validator: (v) => Validators.requiredField(v, 'Course'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _yearController.text.isNotEmpty ? _yearController.text : '1st Year',
                      decoration: const InputDecoration(labelText: 'Year'),
                      items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
                          .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (val) => setState(() => _yearController.text = val ?? '1st Year'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _sectionHeader('Contact & Guardian Details', Icons.contacts_rounded),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _parentNameController,
                label: 'Parent / Guardian Name',
                validator: (v) => Validators.requiredField(v, 'Parent Name'),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _parentPhoneController,
                      label: 'Parent Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _emergencyContactController,
                      label: 'Emergency Contact',
                      keyboardType: TextInputType.phone,
                      hint: 'Optional / Parent phone',
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _addressController,
                label: 'Permanent Address',
                maxLines: 2,
                validator: (v) => Validators.requiredField(v, 'Address'),
              ),

              const SizedBox(height: 20),
              _sectionHeader('Hostel & Fee Allocation', Icons.hotel_rounded),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _selectedRoomNumber,
                      decoration: const InputDecoration(labelText: 'Room Allocation'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('No Room (Unallocated)')),
                        ...rooms.map((r) {
                          final occupants = _mongo.getStudentsInRoom(r.roomNumber);
                          final isCurrent = widget.studentToEdit?.roomNumber == r.roomNumber;
                          final isFull = occupants.length >= r.totalBeds && !isCurrent;
                          return DropdownMenuItem<String?>(
                            value: r.roomNumber,
                            enabled: !isFull,
                            child: Text(
                              '${r.roomNumber} (${r.roomType}) - ${isFull ? "FULL" : "${r.totalBeds - occupants.length} beds free"}',
                              style: TextStyle(color: isFull ? Colors.grey : null),
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() => _selectedRoomNumber = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _feeAmountController,
                      label: 'Total Hostel Fee (₹)',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.validateNumber(v, 'Fee amount'),
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: _admissionDateController,
                label: 'Admission Date (YYYY-MM-DD)',
                validator: (v) => Validators.requiredField(v, 'Admission date'),
              ),

              const SizedBox(height: 28),
              CustomButton(
                text: _isEditing ? 'Update Student Record' : 'Save & Register Student',
                icon: Icons.check_circle_rounded,
                isLoading: _isLoading,
                onPressed: _saveStudent,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}
