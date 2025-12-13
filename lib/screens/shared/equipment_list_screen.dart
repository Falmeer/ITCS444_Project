// lib/screens/shared/equipment_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/equipment.dart';
import '../../services/fake_data_services.dart';
import '../../widgets/equipment_card.dart';

class EquipmentListScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final items = dataService.equipments;

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final eq = items[index];
        return EquipmentCard(
          equipment: eq,
          showAdminActions: showAdminActions,
          onTap: onItemTap != null ? () => onItemTap!(eq) : null,
        );
      },
    );
  }
}
