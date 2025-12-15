// lib/models/user.dart
enum UserRole { admin, renter, guest }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String preferredContactMethod;
  final UserRole role;
  // Additional profile/auth fields
  final String nationalId; // 9-digit civil ID
  final String? password; // stored in-memory for this demo only

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.preferredContactMethod,
    required this.role,
    this.nationalId = '',
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'preferredContactMethod': preferredContactMethod,
      'role': role.name,
      'nationalId': nationalId,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      preferredContactMethod:
          (map['preferredContactMethod'] as String?) ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] as String? ?? 'guest'),
        orElse: () => UserRole.guest,
      ),
      nationalId: (map['nationalId'] as String?) ?? '',
      password: map['password'] as String?,
    );
  }
}
