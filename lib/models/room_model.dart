import '../utils/constants.dart';

class RoomModel {
  final String id;
  final String roomNumber;
  final int floor;
  final String roomType; // 'AC Standard', 'Non-AC Deluxe', etc.
  final int totalBeds;
  final int occupiedBeds;
  final double monthlyFee;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.roomType,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.monthlyFee,
  });

  int get availableBeds => (totalBeds - occupiedBeds).clamp(0, totalBeds);

  bool get isFull => occupiedBeds >= totalBeds;
  bool get isAvailable => occupiedBeds == 0;
  bool get isPartiallyOccupied => occupiedBeds > 0 && occupiedBeds < totalBeds;

  String get status {
    if (isFull) return AppConstants.roomFull;
    if (isAvailable) return AppConstants.roomAvailable;
    return AppConstants.roomPartial;
  }

  RoomModel copyWith({
    String? id,
    String? roomNumber,
    int? floor,
    String? roomType,
    int? totalBeds,
    int? occupiedBeds,
    double? monthlyFee,
  }) {
    return RoomModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      roomType: roomType ?? this.roomType,
      totalBeds: totalBeds ?? this.totalBeds,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      monthlyFee: monthlyFee ?? this.monthlyFee,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'room_id': id,
      'room_number': roomNumber,
      'floor': floor,
      'room_type': roomType,
      'total_beds': totalBeds,
      'occupied_beds': occupiedBeds,
      'monthly_fee': monthlyFee,
      'status': status,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['room_id']?.toString() ?? map['_id']?.toString() ?? map['id']?.toString() ?? '',
      roomNumber: map['room_number'] ?? map['roomNumber'] ?? '',
      floor: (map['floor'] as num?)?.toInt() ?? 1,
      roomType: map['room_type'] ?? map['roomType'] ?? 'Non-AC Standard',
      totalBeds: (map['total_beds'] as num?)?.toInt() ?? 
                 (map['totalBeds'] as num?)?.toInt() ?? 2,
      occupiedBeds: (map['occupied_beds'] as num?)?.toInt() ?? 
                    (map['occupiedBeds'] as num?)?.toInt() ?? 0,
      monthlyFee: (map['monthly_fee'] as num?)?.toDouble() ?? 
                  (map['monthlyFee'] as num?)?.toDouble() ?? 5000.0,
    );
  }
}
