// lib/services/fake_data_service.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/equipment.dart';
import '../models/reservation.dart';
import '../models/donation.dart';

class FakeDataService with ChangeNotifier {
  FakeDataService._internal();

  static final FakeDataService _instance = FakeDataService._internal();

  factory FakeDataService() => _instance;

  final List<Equipment> _equipments = [];
  final List<Reservation> _reservations = [];
  final List<Donation> _donations = [];

  bool _initialized = false;
  late Box _equipBox;
  late Box _reservationsBox;
  late Box _donationsBox;

  List<Equipment> get equipments => List.unmodifiable(_equipments);
  List<Reservation> get reservations => List.unmodifiable(_reservations);
  List<Donation> get donations => List.unmodifiable(_donations);

  Future<void> initialize() async {
    if (_initialized) return;

    _equipBox = await Hive.openBox('equipmentsBox');
    _reservationsBox = await Hive.openBox('reservationsBox');
    _donationsBox = await Hive.openBox('donationsBox');

    _loadFromHive();
    _initialized = true;
  }

  void _loadFromHive() {
    _equipments
      ..clear()
      ..addAll(_equipBox.values.map((value) {
        final map = Map<String, dynamic>.from(value as Map);
        return Equipment.fromMap(map);
      }));

    _reservations
      ..clear()
      ..addAll(_reservationsBox.values.map((value) {
        final map = Map<String, dynamic>.from(value as Map);
        return Reservation.fromMap(map);
      }));

    _donations
      ..clear()
      ..addAll(_donationsBox.values.map((value) {
        final map = Map<String, dynamic>.from(value as Map);
        return Donation.fromMap(map);
      }));

    if (_equipments.isEmpty && _reservations.isEmpty && _donations.isEmpty) {
      _seedData();
      _persistAll();
    }

    notifyListeners();
  }

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

  void _persistAll() {
    for (final e in _equipments) {
      _equipBox.put(e.id, e.toMap());
    }
    for (final r in _reservations) {
      _reservationsBox.put(r.id, r.toMap());
    }
    for (final d in _donations) {
      _donationsBox.put(d.id, d.toMap());
    }
  }

  // Example actions
  void addEquipment(Equipment equipment) {
    _equipments.add(equipment);
    if (_initialized) {
      _equipBox.put(equipment.id, equipment.toMap());
    }
    notifyListeners();
  }

  void updateEquipment(Equipment updated) {
    final index = _equipments.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _equipments[index] = updated;
      if (_initialized) {
        _equipBox.put(updated.id, updated.toMap());
      }
      notifyListeners();
    }
  }

  void deleteEquipment(String id) {
    _equipments.removeWhere((e) => e.id == id);
    if (_initialized) {
      _equipBox.delete(id);
    }
    notifyListeners();
  }

  void addReservation(Reservation reservation) {
    _reservations.add(reservation);
    if (_initialized) {
      _reservationsBox.put(reservation.id, reservation.toMap());
    }
    notifyListeners();
  }

  void addDonation(Donation donation) {
    _donations.add(donation);
    if (_initialized) {
      _donationsBox.put(donation.id, donation.toMap());
    }
    notifyListeners();
  }

  void updateReservationStatus(String id, ReservationStatus status,
      {String? rejectionReason}) {
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
      rejectionReason:
          status == ReservationStatus.declined ? rejectionReason : existing.rejectionReason,
    );

    if (_initialized) {
      _reservationsBox.put(_reservations[index].id, _reservations[index].toMap());
    }

    // Keep equipment status in sync with reservation lifecycle
    final equipmentId = existing.equipment.id;

    if (status == ReservationStatus.approved ||
        status == ReservationStatus.checkedOut) {
      // Once approved/checked out, mark the item as rented so
      // it no longer appears as available for new reservations.
      updateEquipmentStatus(equipmentId, EquipmentStatus.rented);
    } else if (status == ReservationStatus.returned) {
      // When a rental is returned, make the item available again,
      // unless it has been explicitly moved to maintenance.
      final equipIndex = _equipments.indexWhere((e) => e.id == equipmentId);
      if (equipIndex != -1 &&
          _equipments[equipIndex].status != EquipmentStatus.maintenance) {
        updateEquipmentStatus(equipmentId, EquipmentStatus.available);
      }
    }

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
      imageBytes: existing.imageBytes,
    );
    if (_initialized) {
      _equipBox.put(id, _equipments[index].toMap());
    }
    notifyListeners();
  }

  void updateDonationStatus(String id, DonationStatus status,
      {String? rejectionReason}) {
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
      imageBytes: existing.imageBytes,
      status: status,
      createdAt: existing.createdAt,
      rejectionReason:
          status == DonationStatus.rejected ? rejectionReason : existing.rejectionReason,
    );

    if (_initialized) {
      _donationsBox.put(_donations[index].id, _donations[index].toMap());
    }

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
          imageBytes: existing.imageBytes,
        ),
      );
      if (_initialized) {
        final added = _equipments.last;
        _equipBox.put(added.id, added.toMap());
      }
    }

    notifyListeners();
  }
}
