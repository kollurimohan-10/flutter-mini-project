import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/mongo_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';

class StudentRoomScreen extends StatelessWidget {
  const StudentRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = AuthService().currentStudent;
    final mongo = MongoService();
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    if (student == null || !student.isAllocated) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Room')),
        body: EmptyStateView(
          icon: Icons.hotel_outlined,
          title: 'No Room Allocated',
          message: 'You have not been assigned to a hostel room yet. Please contact the hostel warden desk.',
        ),
      );
    }

    final room = mongo.getRoomByNumber(student.roomNumber!);
    final roommates = mongo.getStudentsInRoom(student.roomNumber!).where((s) => s.id != student.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${student.roomNumber}'),
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
                              'Room ${student.roomNumber}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                            Text(
                              room != null ? 'Floor ${room.floor} • ${room.roomType}' : 'Standard Room',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                        if (room != null) StatusBadge(status: room.status),
                      ],
                    ),
                    const Divider(height: 24),
                    if (room != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _specItem('Total Beds', '${room.totalBeds}'),
                          _specItem('Occupied', '${room.occupiedBeds}'),
                          _specItem('Available', '${room.availableBeds}'),
                          _specItem('Monthly Fee', currency.format(room.monthlyFee)),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Roommates Section
            Text(
              'My Roommates (${roommates.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: 8),

            if (roommates.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text('No other roommates allocated to this room yet.'),
                  ),
                ),
              )
            else
              ...roommates.map((rm) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Text(rm.initials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                  ),
                  title: Text(rm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${rm.course} (${rm.year})', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      Text('Phone: ${rm.phone}', style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryBlue)),
                    ],
                  ),
                ),
              )),

            const SizedBox(height: 18),

            // Amenities Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Room Guidelines & Maintenance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                    const SizedBox(height: 10),
                    _ruleBullet('Daily floor sweeping is conducted between 9:00 AM and 11:00 AM.'),
                    _ruleBullet('Turn off all lights, fans, and study lamps when leaving the room.'),
                    _ruleBullet('For electrical or plumbing issues, file a complaint through the app.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _ruleBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.accentTeal),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, height: 1.3))),
        ],
      ),
    );
  }
}
