// lib/services/fake_data_service.dart
import 'package:flutter/foundation.dart';
import '../models/equipment.dart';
import '../models/reservation.dart';
import '../models/donation.dart';

class FakeDataService with ChangeNotifier {
  FakeDataService._internal() {
    _seedData();
  }

  static final FakeDataService _instance = FakeDataService._internal();

  factory FakeDataService() => _instance;

  final List<Equipment> _equipments = [];
  final List<Reservation> _reservations = [];
  final List<Donation> _donations = [];

  List<Equipment> get equipments => List.unmodifiable(_equipments);
  List<Reservation> get reservations => List.unmodifiable(_reservations);
  List<Donation> get donations => List.unmodifiable(_donations);

  void _seedData() {
    _equipments.addAll([
      Equipment(
        id: 'eq1',
        name: 'Wheelchair',
        type: 'Mobility',
        description: 'Standard manual wheelchair.',
        location: 'Main Branch',
        condition: 'Good',
        tags: ['wheelchair', 'mobility'],
        status: EquipmentStatus.available,
        quantity: 3,
        rentalPricePerDay: 2.5,
        imageUrl: null,
      ),
      Equipment(
        id: 'eq2',
        name: 'Walker',
        type: 'Support',
        description: 'Adjustable walker with wheels.',
        location: 'Main Branch',
        condition: 'Very Good',
        tags: ['walker', 'support'],
        status: EquipmentStatus.maintenance,
        quantity: 1,
        rentalPricePerDay: 1.5,
        imageUrl: null,
      ),
    ]);
  }

  // Example actions
  void addEquipment(Equipment equipment) {
    _equipments.add(equipment);
    notifyListeners();
  }

  void updateEquipment(Equipment updated) {
    final index = _equipments.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _equipments[index] = updated;
      notifyListeners();
    }
  }

  void deleteEquipment(String id) {
    _equipments.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addReservation(Reservation reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }

  void addDonation(Donation donation) {
    _donations.add(donation);
    notifyListeners();
  }

  void updateReservationStatus(String id, ReservationStatus status) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final existing = _reservations[index];
    _reservations[index] = Reservation(
      id: existing.id,
      equipment: existing.equipment,
      renter: existing.renter,
      startDate: existing.startDate,
      endDate: existing.endDate,
      status: status,
    );
    notifyListeners();
  }

  void updateEquipmentStatus(String id, EquipmentStatus status) {
    final index = _equipments.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final existing = _equipments[index];
    _equipments[index] = Equipment(
      id: existing.id,
      name: existing.name,
      type: existing.type,
      description: existing.description,
      location: existing.location,
      condition: existing.condition,
      tags: existing.tags,
      status: status,
      quantity: existing.quantity,
      rentalPricePerDay: existing.rentalPricePerDay,
      imageUrl: existing.imageUrl,
    );
    notifyListeners();
  }

  void updateDonationStatus(String id, DonationStatus status) {
    final index = _donations.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final existing = _donations[index];
    _donations[index] = Donation(
      id: existing.id,
      donor: existing.donor,
      itemType: existing.itemType,
      condition: existing.condition,
      description: existing.description,
      imageUrl: existing.imageUrl,
      status: status,
      createdAt: existing.createdAt,
    );

    if (status == DonationStatus.approved) {
      _equipments.add(
        Equipment(
          id: 'don_${existing.id}',
          name: existing.itemType,
          type: existing.itemType,
          description: existing.description,
          location: 'Main Branch',
          condition: existing.condition,
          tags: [existing.itemType.toLowerCase()],
          status: EquipmentStatus.donated,
          quantity: 1,
          rentalPricePerDay: null,
          imageUrl: existing.imageUrl,
        ),
      );
    }

    notifyListeners();
  }
}
