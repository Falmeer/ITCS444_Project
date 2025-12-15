import '../models/user.dart';

class AuthService {
  AuthService._internal() {
    _seedAdmin();
  }

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final List<User> _users = [];

  List<User> get users => List.unmodifiable(_users);

  void _seedAdmin() {
    // Fixed admin accounts
    _users.addAll([
      User(
        id: 'admin_1',
        name: 'Fawaz Almeer',
        email: 'falmeer2002@gmail.com',
        phone: '00000000',
        preferredContactMethod: 'Email',
        role: UserRole.admin,
        nationalId: '000000000',
        password: 'Admin123',
      ),
      User(
        id: 'admin_2',
        name: 'Salman Alhawaj',
        email: 'admin@gmail.com',
        phone: '00000000',
        preferredContactMethod: 'Email',
        role: UserRole.admin,
        nationalId: '000000000',
        password: 'Admin123',
      ),
    ]);
  }

  bool isEmailTaken(String email) {
    final normalized = email.trim().toLowerCase();
    return _users.any((u) => u.email.toLowerCase() == normalized);
  }

  User registerRenter({
    required String fullName,
    required String nationalId,
    required String phone,
    required String email,
    required String password,
    required String preferredContactMethod,
  }) {
    final normalizedEmail = email.trim();
    if (isEmailTaken(normalizedEmail)) {
      throw StateError('Email already in use');
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: fullName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      preferredContactMethod: preferredContactMethod,
      role: UserRole.renter,
      nationalId: nationalId.trim(),
      password: password,
    );

    _users.add(user);
    return user;
  }

  User? login(String email, String password) {
    final normalized = email.trim().toLowerCase();
    try {
      return _users.firstWhere(
        (u) =>
            u.email.toLowerCase() == normalized && (u.password ?? '') == password,
      );
    } catch (_) {
      return null;
    }
  }
}
