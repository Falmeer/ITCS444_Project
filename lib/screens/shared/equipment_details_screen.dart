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
        (equipment.status == EquipmentStatus.available ||
            equipment.status == EquipmentStatus.donated);

    return Scaffold(
      appBar: AppBar(
        title: Text(equipment.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              equipment.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${equipment.type} • ${equipment.location}'),
            const SizedBox(height: 8),
            Text('Condition: ${equipment.condition}'),
            const SizedBox(height: 8),
            if (equipment.rentalPricePerDay != null)
              Text('Price: ${equipment.rentalPricePerDay!.toStringAsFixed(1)} BD/day'),
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
            const Spacer(),
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
                'Only renters can reserve, and only available/donated items can be reserved.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
