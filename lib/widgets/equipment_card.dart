// lib/widgets/equipment_card.dart
import 'package:flutter/material.dart';
import '../models/equipment.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final bool showAdminActions;
  final VoidCallback? onTap;

  const EquipmentCard({
    super.key,
    required this.equipment,
    this.showAdminActions = false,
    this.onTap,
  });

  String _statusText(EquipmentStatus status) {
    switch (status) {
      case EquipmentStatus.available:
        return 'Available';
      case EquipmentStatus.rented:
        return 'Rented';
      case EquipmentStatus.donated:
        return 'Donated';
      case EquipmentStatus.maintenance:
        return 'Under Maintenance';
    }
  }

  Color _statusColor(EquipmentStatus status) {
    switch (status) {
      case EquipmentStatus.available:
        return Colors.green;
      case EquipmentStatus.rented:
        return Colors.orange;
      case EquipmentStatus.donated:
        return Colors.blueGrey;
      case EquipmentStatus.maintenance:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(equipment.name[0]),
        ),
        title: Text(equipment.name),
        subtitle: Text(
          '${equipment.type} • ${equipment.location}\nCondition: ${equipment.condition}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusText(equipment.status),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _statusColor(equipment.status),
              ),
            ),
            if (equipment.rentalPricePerDay != null)
              Text('${equipment.rentalPricePerDay!.toStringAsFixed(1)} BD/day'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
