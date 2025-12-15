// lib/screens/renter/renter_home_screen.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/fake_data_services.dart';
import '../shared/equipment_list_screen.dart';
import '../shared/donation_form.dart';
import '../auth/login_screen.dart';
import '../shared/equipment_details_screen.dart';
import '../shared/profile_screen.dart';
import '../shared/notifications_screen.dart';
import 'my_reservations_screen.dart';

class RenterHomeScreen extends StatefulWidget {
  final User user;
  const RenterHomeScreen({super.key, required this.user});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  final FakeDataService _dataService = FakeDataService();
  int _selectedIndex = 0;

  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Browse equipment
      EquipmentListScreen(
        dataService: _dataService,
        onItemTap: (equipment) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EquipmentDetailsScreen(
              equipment: equipment,
              user: _user,
              dataService: _dataService,
            ),
          ),
        ),
      ),
      // My rentals (to be implemented in reservation phase)
      MyReservationsScreen(user: _user, dataService: _dataService),
      // Donations from renter
      DonationForm(user: _user, dataService: _dataService),
      // Profile / account info
      ProfileScreen(
        user: _user,
        onUserUpdated: (updated) {
          setState(() {
            _user = updated;
          });
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Renter - ${_user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(
                    user: _user,
                    dataService: _dataService,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Switch user / Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'My Rentals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
