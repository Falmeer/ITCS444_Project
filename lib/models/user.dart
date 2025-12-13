// lib/models/user.dart
enum UserRole { admin, renter, guest }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String preferredContactMethod;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.preferredContactMethod,
    required this.role,
  });
}
