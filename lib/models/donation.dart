// lib/models/donation.dart
import 'user.dart';

enum DonationStatus { pendingApproval, approved, rejected }

class Donation {
  final String id;
  final User donor;
  final String itemType;
  final String condition;
  final String description;
  final String? imageUrl;
  final DonationStatus status;
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.donor,
    required this.itemType,
    required this.condition,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.createdAt,
  });
}
