// lib/models/reservation.dart
import 'equipment.dart';
import 'user.dart';

enum ReservationStatus { pending, approved, declined, checkedOut, returned }

class Reservation {
  final String id;
  final Equipment equipment;
  final User renter;
  final DateTime startDate;
  final DateTime endDate;
  final ReservationStatus status;
  final String? rejectionReason;

  Reservation({
    required this.id,
    required this.equipment,
    required this.renter,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.rejectionReason,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipment': equipment.toMap(),
      'renter': renter.toMap(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] as String,
      equipment:
          Equipment.fromMap(Map<String, dynamic>.from(map['equipment'] as Map)),
      renter: User.fromMap(
          Map<String, dynamic>.from(map['renter'] as Map)),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      status: ReservationStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String? ?? 'pending'),
        orElse: () => ReservationStatus.pending,
      ),
      rejectionReason: map['rejectionReason'] as String?,
    );
  }
}
