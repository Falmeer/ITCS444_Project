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

  Reservation({
    required this.id,
    required this.equipment,
    required this.renter,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;
}
