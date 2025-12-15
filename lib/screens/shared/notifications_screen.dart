import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/reservation.dart';
import '../../models/donation.dart';
import '../../models/equipment.dart';
import '../../services/fake_data_services.dart';

class NotificationsScreen extends StatelessWidget {
  final User user;
  final FakeDataService dataService;

  const NotificationsScreen({
    super.key,
    required this.user,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    final reservations = dataService.reservations;
    final donations = dataService.donations;
    final equipments = dataService.equipments;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isAdmin = user.role == UserRole.admin;
    final isRenter = user.role == UserRole.renter;

    final List<Widget> sections = [];

    if (isRenter) {
      final myReservations = reservations
          .where((r) => r.renter.email == user.email)
          .toList();

      final dueSoon = myReservations.where((r) {
        if (r.status != ReservationStatus.approved &&
            r.status != ReservationStatus.checkedOut) {
          return false;
        }
        final dueDate = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
        final daysLeft = dueDate.difference(today).inDays;
        // Due today or in the next 1–2 days.
        return daysLeft >= 0 && daysLeft <= 2;
      }).toList();

      final overdue = myReservations.where((r) {
        if (r.status != ReservationStatus.approved &&
            r.status != ReservationStatus.checkedOut) {
          return false;
        }
        final dueDate = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
        // Only dates strictly before today are overdue (yesterday or earlier).
        return dueDate.isBefore(today);
      }).toList();

      final declined = myReservations
          .where((r) => r.status == ReservationStatus.declined)
          .toList();

      sections.addAll([
        _Section(
          title: 'Rentals due soon',
          children: dueSoon.isEmpty
              ? const [Text('No rentals due in the next 2 days.')]
              : dueSoon
                  .map(
                    (r) => ListTile(
                      leading: const Icon(Icons.notifications_active),
                      title: Text(r.equipment.name),
                      subtitle: Text(
                          () {
                            final dueDate = DateTime(
                                r.endDate.year, r.endDate.month, r.endDate.day);
                            final daysLeft =
                                dueDate.difference(today).inDays;
                            return 'Due on ${_formatDate(r.endDate)} ($daysLeft day(s) left)';
                          }(),
                        ),
                    ),
                  )
                  .toList(),
        ),
        _Section(
          title: 'Overdue rentals',
          children: overdue.isEmpty
              ? const [Text('No overdue rentals.')] 
              : overdue
                  .map(
                    (r) => ListTile(
                      leading: const Icon(Icons.warning_amber,
                          color: Colors.redAccent),
                      title: Text(r.equipment.name),
                      subtitle: Text(
                          () {
                            final dueDate = DateTime(
                                r.endDate.year, r.endDate.month, r.endDate.day);
                            final daysPast =
                                today.difference(dueDate).inDays;
                            return 'Overdue since ${_formatDate(r.endDate)} ($daysPast day(s) ago)';
                          }(),
                        ),
                    ),
                  )
                  .toList(),
        ),
        _Section(
          title: 'Declined requests',
          children: declined.isEmpty
              ? const [Text('No declined requests.')] 
              : declined
                  .map(
                    (r) => ListTile(
                      leading: const Icon(Icons.cancel, color: Colors.redAccent),
                      title: Text(r.equipment.name),
                      subtitle: Text(
                        r.rejectionReason != null && r.rejectionReason!.isNotEmpty
                            ? 'Reason: ${r.rejectionReason}'
                            : 'Your request was declined.',
                      ),
                    ),
                  )
                  .toList(),
        ),
      ]);
    }

    if (isAdmin) {
      final pendingReservations = reservations
          .where((r) => r.status == ReservationStatus.pending)
          .toList();
      final overdueAll = reservations.where((r) {
        if (r.status != ReservationStatus.approved &&
            r.status != ReservationStatus.checkedOut) {
          return false;
        }
        final dueDate = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
        // Only dates strictly before today are overdue (yesterday or earlier).
        return dueDate.isBefore(today);
      }).toList();

      final pendingDonations = donations
          .where((d) => d.status == DonationStatus.pendingApproval)
          .toList();

      final maintenanceItems = equipments
          .where((e) => e.status == EquipmentStatus.maintenance)
          .toList();

      sections.addAll([
        _Section(
          title: 'Pending reservations',
          children: pendingReservations.isEmpty
              ? const [Text('No pending reservations.')] 
              : pendingReservations
                  .map(
                    (r) => ListTile(
                      leading: const Icon(Icons.assignment),
                      title: Text(r.equipment.name),
                      subtitle: Text(
                          'From ${_formatDate(r.startDate)} to ${_formatDate(r.endDate)} - ${r.renter.name}'),
                    ),
                  )
                  .toList(),
        ),
        _Section(
          title: 'Overdue rentals',
          children: overdueAll.isEmpty
              ? const [Text('No overdue rentals.')] 
              : overdueAll
                  .map(
                    (r) => ListTile(
                      leading: const Icon(Icons.warning_amber,
                          color: Colors.redAccent),
                      title: Text(r.equipment.name),
                      subtitle: Text(
                          'Renter: ${r.renter.name} - due ${_formatDate(r.endDate)}'),
                    ),
                  )
                  .toList(),
        ),
        _Section(
          title: 'New donation submissions',
          children: pendingDonations.isEmpty
              ? const [Text('No pending donations.')] 
              : pendingDonations
                  .map(
                    (d) => ListTile(
                      leading: const Icon(Icons.volunteer_activism),
                      title: Text(d.itemType),
                      subtitle: Text('Donor: ${d.donor.name}'),
                    ),
                  )
                  .toList(),
        ),
        _Section(
          title: 'Equipment needing maintenance',
          children: maintenanceItems.isEmpty
              ? const [Text('No equipment marked for maintenance.')] 
              : maintenanceItems
                  .map(
                    (e) => ListTile(
                      leading: const Icon(Icons.build),
                      title: Text(e.name),
                      subtitle: Text('Location: ${e.location}'),
                    ),
                  )
                  .toList(),
        ),
      ]);
    }

    if (!isAdmin && !isRenter) {
      final myDonations = donations
          .where((d) => d.donor.email == user.email)
          .toList();
      final pendingMy = myDonations
          .where((d) => d.status == DonationStatus.pendingApproval)
          .toList();
      final reviewedMy = myDonations
          .where((d) => d.status != DonationStatus.pendingApproval)
          .toList();

      sections.addAll([
        _Section(
          title: 'Your pending donations',
          children: pendingMy.isEmpty
              ? const [Text('No pending donations.')] 
              : pendingMy
                  .map(
                    (d) => ListTile(
                      leading: const Icon(Icons.volunteer_activism),
                      title: Text(d.itemType),
                      subtitle: const Text('Awaiting review by admin'),
                    ),
                  )
                  .toList(),
        ),
        _Section(
          title: 'Reviewed donations',
          children: reviewedMy.isEmpty
              ? const [Text('No reviewed donations yet.')] 
              : reviewedMy
                  .map(
                    (d) => ListTile(
                      leading: Icon(
                        d.status == DonationStatus.approved
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: d.status == DonationStatus.approved
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                      title: Text(d.itemType),
                      subtitle: Text(
                        d.status == DonationStatus.approved
                            ? 'Approved'
                            : (d.rejectionReason != null &&
                                    d.rejectionReason!.isNotEmpty
                                ? 'Rejected: ${d.rejectionReason}'
                                : 'Rejected'),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: sections.isEmpty
          ? const Center(child: Text('No notifications right now.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => sections[index],
            ),
    );
  }

  static String _formatDate(DateTime d) => '${d.toLocal()}'.split(' ')[0];
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
