import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../../models/user.dart';
import '../../services/fake_data_services.dart';
import '../renter/reservation_form_screen.dart';

class EquipmentDetailsScreen extends StatelessWidget {
  final Equipment equipment;
  final User user;
  final FakeDataService dataService;

  const EquipmentDetailsScreen({
    super.key,
    required this.equipment,
    required this.user,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    final canReserve = user.role == UserRole.renter &&
        equipment.status == EquipmentStatus.available;

    return Scaffold(
      appBar: AppBar(
        title: Text(equipment.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (equipment.imageBytes != null ||
                (equipment.imageUrl != null &&
                    equipment.imageUrl!.trim().isNotEmpty))
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: equipment.imageBytes != null
                      ? Image.memory(
                          equipment.imageBytes!,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          equipment.imageUrl!.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Text('Image could not be loaded'),
                          ),
                        ),
                ),
              ),
            if (equipment.imageBytes != null ||
                (equipment.imageUrl != null &&
                    equipment.imageUrl!.trim().isNotEmpty))
              const SizedBox(height: 16),
            Text(
              equipment.name,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ID: ${equipment.id}'),
            const SizedBox(height: 4),
            Text('${equipment.type} • ${equipment.location}'),
            const SizedBox(height: 8),
            Text('Condition: ${equipment.condition}'),
            const SizedBox(height: 8),
            if (equipment.rentalPricePerDay != null)
              Text(
                  'Price: ${equipment.rentalPricePerDay!.toStringAsFixed(1)} BD/day'),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(equipment.description.isEmpty
                ? 'No description provided.'
                : equipment.description),
            const SizedBox(height: 16),
            if (equipment.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: equipment.tags
                    .map((t) => Chip(label: Text(t)))
                    .toList(),
              ),
            const SizedBox(height: 24),
            if (canReserve)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReservationFormScreen(
                          equipment: equipment,
                          renter: user,
                          dataService: dataService,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Reserve this equipment'),
                ),
              )
            else
              const Text(
                'Only renters can reserve, and only items marked as Available can be reserved. Rented, Donated, or Under Maintenance items are not rentable.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
