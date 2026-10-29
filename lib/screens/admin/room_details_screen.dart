import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mongo_service.dart';
import '../../models/room_model.dart';
import '../../models/student_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';

class RoomDetailsScreen extends StatefulWidget {
  final String roomId;

  const RoomDetailsScreen({super.key, required this.roomId});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final _mongo = MongoService();
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  RoomModel? _room;
  List<StudentModel> _occupants = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      final rooms = _mongo.getRooms();
      _room = rooms.firstWhere((r) => r.id == widget.roomId, orElse: () => rooms.first);
      if (_room != null) {
        _occupants = _mongo.getStudentsInRoom(_room!.roomNumber);
      }
    });
  }

  void _showAllocateModal() {
    if (_room == null) return;
    if (_occupants.length >= _room!.totalBeds) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot allocate: Room has reached maximum bed capacity!'), backgroundColor: AppTheme.statusDanger),
      );
      return;
    }

    final unallocated = _mongo.getStudents().where((s) => s.roomNumber == null || s.roomNumber != _room!.roomNumber).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Allocate Student to ${_room!.roomNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${_room!.totalBeds - _occupants.length} beds free',
                    style: const TextStyle(color: AppTheme.statusSuccess, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (unallocated.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: Text('No unallocated students available.')),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: unallocated.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final stu = unallocated[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text(stu.initials, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(stu.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${stu.id} • ${stu.course} (${stu.isAllocated ? "Current: ${stu.roomNumber}" : "Unallocated"})'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          onPressed: () async {
                            final success = await _mongo.allocateStudentToRoom(stu.id, _room!.roomNumber);
                            if (mounted) {
                              Navigator.pop(ctx);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${stu.name} allocated to ${_room!.roomNumber}'), backgroundColor: AppTheme.statusSuccess),
                                );
                                _loadData();
                              }
                            }
                          },
                          child: const Text('Allocate', style: TextStyle(fontSize: 12)),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _vacateOccupant(StudentModel student) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Vacate Bed',
      message: 'Remove ${student.name} from room ${_room!.roomNumber}?',
      confirmText: 'Remove',
      confirmColor: Colors.orange.shade800,
    );

    if (confirmed) {
      await _mongo.vacateStudent(student.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.name} vacated from room'), backgroundColor: AppTheme.statusSuccess),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Room Details')),
        body: const Center(child: Text('Room not found')),
      );
    }

    final r = _room!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${r.roomNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Room',
            onPressed: () {
              Navigator.pushNamed(context, '/room_form', arguments: r).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Room ${r.roomNumber}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                            Text(
                              'Floor ${r.floor} • ${r.roomType}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                        StatusBadge(status: r.status),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricItem('Total Beds', '${r.totalBeds}', Icons.hotel_rounded, AppTheme.primaryBlue),
                        _metricItem('Occupied', '${_occupants.length}', Icons.person_rounded, r.isFull ? AppTheme.statusDanger : Colors.orange),
                        _metricItem('Available', '${(r.totalBeds - _occupants.length).clamp(0, r.totalBeds)}', Icons.check_circle_outline, AppTheme.statusSuccess),
                        _metricItem('Monthly Rent', _currency.format(r.monthlyFee), Icons.currency_rupee_rounded, Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Visual Bed Indicators
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bed Allocation Grid',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(r.totalBeds, (index) {
                        final isOccupied = index < _occupants.length;
                        final occupant = isOccupied ? _occupants[index] : null;

                        return Container(
                          width: 140,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isOccupied ? Colors.blue.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOccupied ? AppTheme.primaryBlue : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Bed ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isOccupied ? AppTheme.primaryBlue : Colors.grey.shade600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.hotel_rounded,
                                    size: 16,
                                    color: isOccupied ? AppTheme.primaryBlue : Colors.grey.shade400,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isOccupied ? occupant!.name : 'Empty Bed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: isOccupied ? Colors.black87 : Colors.grey.shade500,
                                ),
                              ),
                              if (isOccupied)
                                Text(
                                  occupant!.id,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current Occupants List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Occupants (${_occupants.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy),
                ),
                if (_occupants.length < r.totalBeds)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                    label: const Text('Allocate Bed', style: TextStyle(fontSize: 12.5)),
                    onPressed: _showAllocateModal,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (_occupants.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('This room currently has no student occupants.'),
                  ),
                ),
              )
            else
              ..._occupants.map((s) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Text(s.initials, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                  subtitle: Text('${s.id} • ${s.course} • Ph: ${s.phone}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_remove_rounded, color: AppTheme.statusDanger),
                    tooltip: 'Vacate Bed',
                    onPressed: () => _vacateOccupant(s),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/student_details', arguments: s.id).then((_) => _loadData());
                  },
                ),
              )),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _metricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
