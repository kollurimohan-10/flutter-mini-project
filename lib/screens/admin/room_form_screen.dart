import 'package:flutter/material.dart';
import '../../services/mongo_service.dart';
import '../../models/room_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RoomFormScreen extends StatefulWidget {
  final RoomModel? roomToEdit;

  const RoomFormScreen({super.key, this.roomToEdit});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mongo = MongoService();

  late TextEditingController _roomNumberController;
  late TextEditingController _floorController;
  late TextEditingController _bedsController;
  late TextEditingController _feeController;

  String _roomType = 'Non-AC Standard';
  bool _isLoading = false;

  bool get _isEditing => widget.roomToEdit != null;

  @override
  void initState() {
    super.initState();
    final r = widget.roomToEdit;
    _roomNumberController = TextEditingController(text: r?.roomNumber ?? '');
    _floorController = TextEditingController(text: r?.floor.toString() ?? '1');
    _bedsController = TextEditingController(text: r?.totalBeds.toString() ?? '2');
    _feeController = TextEditingController(text: r != null ? r.monthlyFee.toStringAsFixed(0) : '5000');
    _roomType = r?.roomType ?? AppConstants.roomTypes.first;
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _floorController.dispose();
    _bedsController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    final roomNo = _roomNumberController.text.trim();
    final existing = _mongo.getRoomByNumber(roomNo);
    if (!_isEditing && existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room $roomNo already exists! Choose another number.'), backgroundColor: AppTheme.statusDanger),
      );
      return;
    }

    setState(() => _isLoading = true);

    final totalBeds = int.tryParse(_bedsController.text.trim()) ?? 2;
    final floor = int.tryParse(_floorController.text.trim()) ?? 1;
    final fee = double.tryParse(_feeController.text.trim()) ?? 5000.0;

    final room = RoomModel(
      id: widget.roomToEdit?.id ?? 'R${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      roomNumber: roomNo,
      floor: floor,
      roomType: _roomType,
      totalBeds: totalBeds,
      occupiedBeds: widget.roomToEdit?.occupiedBeds ?? 0,
      monthlyFee: fee,
    );

    if (_isEditing) {
      await _mongo.updateRoom(room);
    } else {
      await _mongo.addRoom(room);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Room updated successfully' : 'Room added successfully'),
          backgroundColor: AppTheme.statusSuccess,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Room' : 'Add New Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _roomNumberController,
                        label: 'Room Number / Code',
                        hint: 'e.g. A-101, B-205',
                        prefixIcon: Icons.meeting_room_rounded,
                        validator: (v) => Validators.requiredField(v, 'Room number'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _floorController,
                              label: 'Floor Number',
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.validateNumber(v, 'Floor'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _bedsController,
                              label: 'Total Bed Capacity',
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.validateNumber(v, 'Beds'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _roomType,
                        decoration: const InputDecoration(labelText: 'Room Type & Amenities'),
                        items: AppConstants.roomTypes
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _roomType = val ?? AppConstants.roomTypes.first),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _feeController,
                        label: 'Monthly Fee per Student (₹)',
                        prefixIcon: Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.validateNumber(v, 'Monthly fee'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: _isEditing ? 'Update Room' : 'Save Room',
                icon: Icons.check_circle_rounded,
                isLoading: _isLoading,
                onPressed: _saveRoom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
