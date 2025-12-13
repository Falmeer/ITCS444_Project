// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/equipment.dart';
import '../../services/fake_data_services.dart';
import '../shared/equipment_list_screen.dart';
import '../auth/login_screen.dart';
import 'admin_donations_screen.dart';
import 'equipment_form_screen.dart';
import 'admin_reservations_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final User user;
  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FakeDataService _dataService = FakeDataService();
  int _selectedIndex = 0;

  void _showEquipmentActions(BuildContext context, Equipment equipment) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit equipment'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EquipmentFormScreen(
                        dataService: _dataService,
                        equipment: equipment,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Delete equipment'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _dataService.deleteEquipment(equipment.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Equipment deleted')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      EquipmentListScreen(
        dataService: _dataService,
        showAdminActions: true,
        onItemTap: (equipment) => _showEquipmentActions(context, equipment),
      ),
      AdminReservationsScreen(dataService: _dataService),
      AdminDonationsScreen(dataService: _dataService),
      const Center(child: Text('Reports & Statistics (TODO)')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - ${widget.user.name}'),
        actions: [
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EquipmentFormScreen(
                      dataService: _dataService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add equipment'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2), label: 'Inventory'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Reservations'),
          BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }
}
