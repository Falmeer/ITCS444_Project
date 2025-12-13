import 'package:flutter/material.dart';

import '../../models/reservation.dart';
import '../../models/user.dart';
import '../../services/fake_data_services.dart';

class MyReservationsScreen extends StatelessWidget {
  final User user;
  final FakeDataService dataService;

  const MyReservationsScreen({
    super.key,
    required this.user,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    final myReservations = dataService.reservations
        // Match by email so logging in again with the same
        // email shows previous reservations, even if a new
        // User id was generated.
        .where((r) => r.renter.email == user.email)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (myReservations.isEmpty) {
      return const Center(
        child: Text('You have no reservations yet.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myReservations.length,
      itemBuilder: (context, index) {
        final r = myReservations[index];
        final remaining = r.endDate.difference(DateTime.now()).inDays;
        final statusText = _statusText(r.status);
        final statusColor = _statusColor(r.status);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(r.equipment.name),
            subtitle: Text(
              'From ${_formatDate(r.startDate)} to ${_formatDate(r.endDate)}\n'
              'Status: $statusText',
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
                if (r.status == ReservationStatus.approved ||
                    r.status == ReservationStatus.checkedOut)
                  Text(
                    remaining >= 0
                        ? '$remaining day(s) left'
                        : 'Overdue by ${remaining.abs()} day(s)',
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ),
        );
      },
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

  Color _statusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.approved:
        return Colors.green;
      case ReservationStatus.declined:
        return Colors.redAccent;
      case ReservationStatus.checkedOut:
        return Colors.blue;
      case ReservationStatus.returned:
        return Colors.grey;
    }
  }
}
