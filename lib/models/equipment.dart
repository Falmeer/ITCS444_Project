// lib/models/equipment.dart
import 'dart:typed_data';

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
  final Uint8List? imageBytes;

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
    this.imageBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'location': location,
      'condition': condition,
      'tags': tags,
      'rentalPricePerDay': rentalPricePerDay,
      'status': status.name,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'imageBytes': imageBytes,
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      description: map['description'] as String,
      location: map['location'] as String,
      condition: map['condition'] as String,
      tags: (map['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      status: EquipmentStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String? ?? 'available'),
        orElse: () => EquipmentStatus.available,
      ),
      quantity: (map['quantity'] as num).toInt(),
      rentalPricePerDay:
          (map['rentalPricePerDay'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] as String?,
      imageBytes: map['imageBytes'] as Uint8List?,
    );
  }
}
