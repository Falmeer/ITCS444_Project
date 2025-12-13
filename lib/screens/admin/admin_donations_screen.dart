import 'package:flutter/material.dart';

import '../../models/donation.dart';
import '../../services/fake_data_services.dart';

class AdminDonationsScreen extends StatefulWidget {
  final FakeDataService dataService;

  const AdminDonationsScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<AdminDonationsScreen> createState() => _AdminDonationsScreenState();
}

class _AdminDonationsScreenState extends State<AdminDonationsScreen> {
  @override
  Widget build(BuildContext context) {
    final donations = widget.dataService.donations;

    final pending = donations
        .where((d) => d.status == DonationStatus.pendingApproval)
        .toList();
    final others = donations
        .where((d) => d.status != DonationStatus.pendingApproval)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pending Donations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (pending.isEmpty)
          const Text('No pending donations.'),
        ...pending.map(_buildPendingTile),
        const SizedBox(height: 24),
        const Text(
          'Reviewed Donations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (others.isEmpty)
          const Text('No reviewed donations yet.'),
        ...others.map(_buildReviewedTile),
      ],
    );
  }

  Widget _buildPendingTile(Donation donation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(donation.itemType),
        subtitle: Text(
          'Donor: ${donation.donor.name}\nCondition: ${donation.condition}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              tooltip: 'Reject',
              onPressed: () {
                widget.dataService
                    .updateDonationStatus(donation.id, DonationStatus.rejected);
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: 'Approve & add to inventory',
              onPressed: () {
                widget.dataService.updateDonationStatus(
                    donation.id, DonationStatus.approved);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Donation approved and added to inventory'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewedTile(Donation donation) {
    final isApproved = donation.status == DonationStatus.approved;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(donation.itemType),
        subtitle: Text(
          'Donor: ${donation.donor.name}\nStatus: ${isApproved ? 'Approved' : 'Rejected'}',
        ),
        isThreeLine: true,
        trailing: Icon(
          isApproved ? Icons.check_circle : Icons.cancel,
          color: isApproved ? Colors.green : Colors.redAccent,
        ),
      ),
    );
  }
}
