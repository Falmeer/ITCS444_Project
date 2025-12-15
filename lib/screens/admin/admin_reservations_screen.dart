import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../../models/reservation.dart';
import '../../services/fake_data_services.dart';

class AdminReservationsScreen extends StatefulWidget {
  final FakeDataService dataService;

  const AdminReservationsScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<AdminReservationsScreen> createState() => _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  @override
  Widget build(BuildContext context) {
    final reservations = widget.dataService.reservations.toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final pending =
        reservations.where((r) => r.status == ReservationStatus.pending).toList();
    final active = reservations
        .where((r) =>
            r.status == ReservationStatus.approved ||
            r.status == ReservationStatus.checkedOut)
        .toList();
    final history = reservations
        .where((r) =>
            r.status == ReservationStatus.declined ||
            r.status == ReservationStatus.returned)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pending approvals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (pending.isEmpty) const Text('No pending reservations.'),
        ...pending.map(_buildPendingTile),
        const SizedBox(height: 24),
        const Text(
          'Active rentals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (active.isEmpty) const Text('No active rentals.'),
        ...active.map(_buildActiveTile),
        const SizedBox(height: 24),
        const Text(
          'History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (history.isEmpty) const Text('No historical reservations yet.'),
        ...history.map(_buildHistoryTile),
      ],
    );
  }

  Widget _buildPendingTile(Reservation r) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(r.equipment.name),
        subtitle: Text(
          'Renter: ${r.renter.name}\n'
          'From ${_formatDate(r.startDate)} to ${_formatDate(r.endDate)}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              tooltip: 'Decline',
              onPressed: () {
                showDialog<String?>(
                  context: context,
                  builder: (ctx) {
                    final controller = TextEditingController();
                    return AlertDialog(
                      title: const Text('Reason for rejection'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Optional: explain why this was declined',
                        ),
                        maxLines: 3,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                ).then((reason) {
                  widget.dataService.updateReservationStatus(
                    r.id,
                    ReservationStatus.declined,
                    rejectionReason: (reason != null && reason.isNotEmpty)
                        ? reason
                        : null,
                  );
                  setState(() {});
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: 'Approve',
              onPressed: () {
                final hasConflictingApproved = widget
                    .dataService.reservations
                    .any((other) {
                  if (other.id == r.id) return false;
                  if (other.equipment.id != r.equipment.id) return false;
                  if (other.status != ReservationStatus.approved &&
                      other.status != ReservationStatus.checkedOut) {
                    return false;
                  }
                  final overlaps =
                      !(r.endDate.isBefore(other.startDate) ||
                        r.startDate.isAfter(other.endDate));
                  return overlaps;
                });

                if (hasConflictingApproved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cannot approve this request because it conflicts with an existing approved rental for this item.',
                      ),
                    ),
                  );
                  return;
                }

                widget.dataService
                    .updateReservationStatus(r.id, ReservationStatus.approved);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTile(Reservation r) {
    final remaining = r.endDate.difference(DateTime.now()).inDays;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(r.equipment.name),
        subtitle: Text(
          'Renter: ${r.renter.name}\n'
          'From ${_formatDate(r.startDate)} to ${_formatDate(r.endDate)}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  r.status == ReservationStatus.approved
                      ? 'Approved'
                      : 'Checked out',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  remaining >= 0
                      ? '$remaining day(s) left'
                      : 'Overdue by ${remaining.abs()} day(s)',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'checkout') {
                  widget.dataService.updateReservationStatus(
                      r.id, ReservationStatus.checkedOut);
                } else if (value == 'returned') {
                  widget.dataService.updateReservationStatus(
                      r.id, ReservationStatus.returned);
                } else if (value == 'maintenance') {
                  widget.dataService.updateReservationStatus(
                      r.id, ReservationStatus.returned);
                  widget.dataService.updateEquipmentStatus(
                      r.equipment.id, EquipmentStatus.maintenance);
                }
                setState(() {});
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(
                  value: 'checkout',
                  child: Text('Mark as checked out'),
                ),
                PopupMenuItem(
                  value: 'returned',
                  child: Text('Mark as returned'),
                ),
                PopupMenuItem(
                  value: 'maintenance',
                  child: Text('Returned & needs maintenance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(Reservation r) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(r.equipment.name),
        subtitle: Text(
          'Renter: ${r.renter.name}\n'
          'From ${_formatDate(r.startDate)} to ${_formatDate(r.endDate)}\n'
          'Status: ${_statusText(r.status)}',
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.toLocal()}'.split(' ')[0];

  String _statusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.approved:
        return 'Approved';
      case ReservationStatus.declined:
        return 'Declined';
      case ReservationStatus.checkedOut:
        return 'Checked out';
      case ReservationStatus.returned:
        return 'Returned';
    }
  }
}
