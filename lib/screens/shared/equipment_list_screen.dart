// lib/screens/shared/equipment_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/equipment.dart';
import '../../services/fake_data_services.dart';
import '../../widgets/equipment_card.dart';

class EquipmentListScreen extends StatefulWidget {
  final FakeDataService dataService;
  final bool showAdminActions;
  final ValueChanged<Equipment>? onItemTap;

  const EquipmentListScreen({
    super.key,
    required this.dataService,
    this.showAdminActions = false,
    this.onItemTap,
  });

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  String _searchQuery = '';
  bool _onlyDonated = false;
  bool _onlyRentable = false;
  String _selectedType = 'All';
  EquipmentStatus? _selectedStatus; // null = all

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.dataService,
      builder: (context, _) {
        final allItems = widget.dataService.equipments;
        const typeOptions = [
          'All',
          'Wheelchair',
          'Walker',
          'Crutches',
          'Hospital Bed',
          'Oxygen Machine',
          'Other',
        ];

        final filtered = allItems.where((eq) {
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            final matchesText = eq.name.toLowerCase().contains(q) ||
                eq.type.toLowerCase().contains(q) ||
                eq.location.toLowerCase().contains(q) ||
                eq.tags.any((t) => t.toLowerCase().contains(q));
            if (!matchesText) return false;
          }

          if (_onlyDonated) {
            return eq.status == EquipmentStatus.donated;
          }

          if (_onlyRentable) {
            // Rentable means items that are currently available to be rented.
            return eq.status == EquipmentStatus.available;
          }

          if (_selectedType != 'All' && eq.type.trim() != _selectedType) {
            return false;
          }

          if (_selectedStatus != null && eq.status != _selectedStatus) {
            return false;
          }

          return true;
        }).toList();

        return Column(
          children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search equipment by name, type, location, or tag',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value.trim());
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Donated only'),
                selected: _onlyDonated,
                onSelected: (selected) {
                  setState(() {
                    _onlyDonated = selected;
                    if (selected) _onlyRentable = false;
                  });
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Rentable only'),
                selected: _onlyRentable,
                onSelected: (selected) {
                  setState(() {
                    _onlyRentable = selected;
                    if (selected) _onlyDonated = false;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  items: typeOptions
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t == 'All' ? 'All types' : t),
                        ),
                      )
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedType = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<EquipmentStatus?>(
                  initialValue: _selectedStatus,
                  items: const [
                    DropdownMenuItem<EquipmentStatus?>(
                      value: null,
                      child: Text('All statuses'),
                    ),
                    DropdownMenuItem<EquipmentStatus?>(
                      value: EquipmentStatus.available,
                      child: Text('Available'),
                    ),
                    DropdownMenuItem<EquipmentStatus?>(
                      value: EquipmentStatus.rented,
                      child: Text('Rented'),
                    ),
                    DropdownMenuItem<EquipmentStatus?>(
                      value: EquipmentStatus.donated,
                      child: Text('Donated'),
                    ),
                    DropdownMenuItem<EquipmentStatus?>(
                      value: EquipmentStatus.maintenance,
                      child: Text('Under maintenance'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Availability',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final eq = filtered[index];
              return EquipmentCard(
                equipment: eq,
                showAdminActions: widget.showAdminActions,
                onTap: widget.onItemTap != null
                    ? () => widget.onItemTap!(eq)
                    : null,
              );
            },
          ),
        ),
      ],
    );
      },
    );
  }
}
