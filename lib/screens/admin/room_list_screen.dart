import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mongo_service.dart';
import '../../models/room_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_view.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final _mongo = MongoService();
  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  String _filter = 'All';

  List<RoomModel> _getFilteredRooms() {
    final list = _mongo.getRooms();
    if (_filter == 'Available') {
      return list.where((r) => r.isAvailable).toList();
    } else if (_filter == 'Partial') {
      return list.where((r) => r.isPartiallyOccupied).toList();
    } else if (_filter == 'Full') {
      return list.where((r) => r.isFull).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _getFilteredRooms();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_home_rounded),
            tooltip: 'Add New Room',
            onPressed: () => Navigator.pushNamed(context, '/room_form').then((_) => setState(() {})),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All Rooms (${_mongo.getRooms().length})', 'All'),
                  const SizedBox(width: 8),
                  _filterChip('Available (${_mongo.getRooms().where((r) => r.isAvailable).length})', 'Available'),
                  const SizedBox(width: 8),
                  _filterChip('Partially Occupied (${_mongo.getRooms().where((r) => r.isPartiallyOccupied).length})', 'Partial'),
                  const SizedBox(width: 8),
                  _filterChip('Full (${_mongo.getRooms().where((r) => r.isFull).length})', 'Full'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: rooms.isEmpty
                ? EmptyStateView(
                    icon: Icons.hotel_outlined,
                    title: 'No Rooms Found',
                    message: 'No rooms found under the "$_filter" filter.',
                    actionText: 'Add New Room',
                    onAction: () => Navigator.pushNamed(context, '/room_form').then((_) => setState(() {})),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final r = rooms[index];
                      final occupants = _mongo.getStudentsInRoom(r.roomNumber);

                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/room_details',
                              arguments: r.id,
                            ).then((_) => setState(() {}));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryNavy.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.meeting_room_rounded, color: AppTheme.primaryNavy, size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Room ${r.roomNumber}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            Text(
                                              'Floor ${r.floor} • ${r.roomType}',
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    StatusBadge(status: r.status),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Bed capacity progress bar
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: r.totalBeds > 0 ? (r.occupiedBeds / r.totalBeds) : 0,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            r.isFull ? AppTheme.statusDanger : AppTheme.statusSuccess,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${r.occupiedBeds} / ${r.totalBeds} Beds',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rent: ${_currency.format(r.monthlyFee)} / month',
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${occupants.length} Occupants',
                                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.primaryBlue),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_rounded),
        label: const Text('Add Room'),
        onPressed: () => Navigator.pushNamed(context, '/room_form').then((_) => setState(() {})),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppTheme.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}
