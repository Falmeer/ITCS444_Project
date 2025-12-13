// lib/models/equipment.dart
enum EquipmentStatus { available, rented, donated, maintenance }

class Equipment {
  final String id;
  final String name;
  final String type;
  final String description;
  final String location;
  final String condition;
  final List<String> tags;
  final double? rentalPricePerDay;
  final EquipmentStatus status;
  final int quantity;
  final String? imageUrl;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.location,
    required this.condition,
    required this.tags,
    required this.status,
    required this.quantity,
    this.rentalPricePerDay,
    this.imageUrl,
  });
}
