// lib/models/donation.dart
import 'dart:typed_data';
import 'user.dart';

enum DonationStatus { pendingApproval, approved, rejected }

class Donation {
  final String id;
  final User donor;
  final String itemType;
  final String condition;
  final String description;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final DonationStatus status;
  final DateTime createdAt;
  final String? rejectionReason;

  Donation({
    required this.id,
    required this.donor,
    required this.itemType,
    required this.condition,
    required this.description,
    this.imageUrl,
    this.imageBytes,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donor': donor.toMap(),
      'itemType': itemType,
      'condition': condition,
      'description': description,
      'imageUrl': imageUrl,
      'imageBytes': imageBytes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      id: map['id'] as String,
      donor: User.fromMap(Map<String, dynamic>.from(map['donor'] as Map)),
      itemType: map['itemType'] as String,
      condition: map['condition'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String?,
      imageBytes: map['imageBytes'] as Uint8List?,
      status: DonationStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String? ?? 'pendingApproval'),
        orElse: () => DonationStatus.pendingApproval,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      rejectionReason: map['rejectionReason'] as String?,
    );
  }
}
