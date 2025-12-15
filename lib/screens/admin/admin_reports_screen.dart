import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../../models/reservation.dart';
import '../../models/donation.dart';
import '../../services/fake_data_services.dart';

class AdminReportsScreen extends StatelessWidget {
  final FakeDataService dataService;

  const AdminReportsScreen({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dataService,
      builder: (context, _) {
        final equipments = dataService.equipments;
        final reservations = dataService.reservations;
        final donations = dataService.donations;

        final totalEquip = equipments.length;
        final availableCount =
            equipments.where((e) => e.status == EquipmentStatus.available).length;
        final rentedCount =
            equipments.where((e) => e.status == EquipmentStatus.rented).length;
        final donatedCount =
            equipments.where((e) => e.status == EquipmentStatus.donated).length;
        final maintenanceCount = equipments
            .where((e) => e.status == EquipmentStatus.maintenance)
            .length;

        final now = DateTime.now();
        final totalReservations = reservations.length;
        final pendingReservations = reservations
            .where((r) => r.status == ReservationStatus.pending)
            .length;
        final activeReservations = reservations
            .where((r) =>
                r.status == ReservationStatus.approved ||
                r.status == ReservationStatus.checkedOut)
            .length;
        final overdueReservations = reservations
            .where((r) =>
                (r.status == ReservationStatus.approved ||
                    r.status == ReservationStatus.checkedOut) &&
                r.endDate.isBefore(now))
            .length;

        final pendingDonations = donations
            .where((d) => d.status == DonationStatus.pendingApproval)
            .length;
        final approvedDonations = donations
            .where((d) => d.status == DonationStatus.approved)
            .length;
        final rejectedDonations = donations
            .where((d) => d.status == DonationStatus.rejected)
            .length;

        final rentalsByEquipmentId = <String, int>{};
        for (final r in reservations) {
          // Only count rentals that have been approved or beyond.
          if (r.status != ReservationStatus.approved &&
              r.status != ReservationStatus.checkedOut &&
              r.status != ReservationStatus.returned) {
            continue;
          }
          rentalsByEquipmentId.update(r.equipment.id, (value) => value + 1,
              ifAbsent: () => 1);
        }
        final topEquipmentEntries = rentalsByEquipmentId.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topEquipment = topEquipmentEntries.take(3).map((entry) {
          final eq = equipments.firstWhere(
            (e) => e.id == entry.key,
            orElse: () => equipments.isNotEmpty
                ? equipments.first
                : Equipment(
                    id: entry.key,
                    name: 'Unknown equipment',
                    type: '',
                    description: '',
                    location: '',
                    condition: '',
                    tags: const [],
                    status: EquipmentStatus.available,
                    quantity: 1,
                  ),
          );
          return _TopEquipmentItem(name: eq.name, rentals: entry.value);
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reports & Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    title: 'Total equipment',
                    value: '$totalEquip',
                    icon: Icons.inventory_2,
                  ),
                  _StatCard(
                    title: 'Available',
                    value: '$availableCount',
                    icon: Icons.check_circle,
                  ),
                  _StatCard(
                    title: 'Rented',
                    value: '$rentedCount',
                    icon: Icons.assignment_turned_in,
                  ),
                  _StatCard(
                    title: 'Donated',
                    value: '$donatedCount',
                    icon: Icons.volunteer_activism,
                  ),
                  _StatCard(
                    title: 'Maintenance',
                    value: '$maintenanceCount',
                    icon: Icons.build,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Reservations overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatRow('Total reservations', '$totalReservations'),
                      _StatRow('Pending approvals', '$pendingReservations'),
                      _StatRow('Active rentals', '$activeReservations'),
                      _StatRow('Overdue rentals', '$overdueReservations'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Donations summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatRow('Pending', '$pendingDonations'),
                      _StatRow('Approved', '$approvedDonations'),
                      _StatRow('Rejected', '$rejectedDonations'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Most frequently rented equipment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (topEquipment.isEmpty)
                const Text('No rental data yet.')
              else
                Card(
                  child: Column(
                    children: topEquipment
                        .map(
                          (item) => ListTile(
                            leading: const Icon(Icons.star),
                            title: Text(item.name),
                            trailing: Text('${item.rentals} rentals'),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TopEquipmentItem {
  final String name;
  final int rentals;

  _TopEquipmentItem({required this.name, required this.rentals});
}
