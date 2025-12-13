// lib/main.dart
import 'package:flutter/material.dart';
import 'models/user.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/renter/renter_home_screen.dart';
import 'screens/guest/guest_home_screen.dart';

void main() {
  runApp(const CareCenterApp());
}

class CareCenterApp extends StatelessWidget {
  const CareCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.teal,
    );

    return MaterialApp(
      title: 'Care Center',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: baseTheme.colorScheme.primary,
          foregroundColor: baseTheme.colorScheme.onPrimary,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: baseTheme.colorScheme.primaryContainer,
          selectedItemColor: baseTheme.colorScheme.onPrimaryContainer,
          unselectedItemColor:
              baseTheme.colorScheme.onPrimaryContainer.withOpacity(0.6),
          showUnselectedLabels: true,
        ),
      ),
      home: const LoginScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/home' && settings.arguments is User) {
          final user = settings.arguments as User;

          switch (user.role) {
            case UserRole.admin:
              return MaterialPageRoute(
                  builder: (_) => AdminHomeScreen(user: user));
            case UserRole.renter:
              return MaterialPageRoute(
                  builder: (_) => RenterHomeScreen(user: user));
            case UserRole.guest:
              return MaterialPageRoute(
                  builder: (_) => GuestHomeScreen(user: user));
          }
        }

        // Fallback
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      },
    );
  }
}
