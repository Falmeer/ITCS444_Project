import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/reservation.dart';
import '../../models/donation.dart';
import '../../models/equipment.dart';
import '../../services/fake_data_services.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final bool showBackButton;
  final ValueChanged<User>? onUserUpdated;

  const ProfileScreen({
    super.key,
    required this.user,
    this.showBackButton = false,
    this.onUserUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalIdController;
  late String _preferredContact;

  final FakeDataService _dataService = FakeDataService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _nationalIdController =
        TextEditingController(text: widget.user.nationalId);
    _preferredContact = widget.user.preferredContactMethod.isEmpty
        ? 'Phone'
        : widget.user.preferredContactMethod;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final updated = User(
      id: widget.user.id,
      name: _nameController.text.trim(),
      email: widget.user.email,
      phone: _phoneController.text.trim(),
      preferredContactMethod: _preferredContact,
      role: widget.user.role,
      nationalId: _nationalIdController.text.trim(),
      password: widget.user.password,
    );

    widget.onUserUpdated?.call(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated (local to this session).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.role.name.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'ID', value: widget.user.id),
                    _InfoRow(label: 'Email', value: widget.user.email),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Role',
                      value: widget.user.role.name.toUpperCase(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Full Name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nationalIdController,
                      decoration: const InputDecoration(
                        labelText: 'National ID (9 digits)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final v = value.trim();
                        if (v.length != 9 || int.tryParse(v) == null) {
                          return 'Must be exactly 9 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone number (8 digits)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final v = value.trim();
                        if (v.length != 8 || int.tryParse(v) == null) {
                          return 'Must be exactly 8 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _preferredContact,
                      items: const [
                        DropdownMenuItem(
                            value: 'Phone', child: Text('Phone')),
                        DropdownMenuItem(
                            value: 'Email', child: Text('Email')),
                        DropdownMenuItem(
                            value: 'WhatsApp', child: Text('WhatsApp')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Preferred Contact Method',
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _preferredContact = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save),
                        label: const Text('Save changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsCard(context),
        ],
      ),
    );

    if (!widget.showBackButton) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: content,
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final user = widget.user;

    if (user.role == UserRole.renter) {
      final myReservations = _dataService.reservations
          .where((r) => r.renter.email == user.email)
          .toList();
      final now = DateTime.now();

      final active = myReservations
          .where((r) =>
              (r.status == ReservationStatus.approved ||
                  r.status == ReservationStatus.checkedOut) &&
              !r.endDate.isBefore(now))
          .length;
      final past = myReservations
          .where((r) => r.status == ReservationStatus.returned)
          .length;
      final overdue = myReservations
          .where((r) =>
              (r.status == ReservationStatus.approved ||
                  r.status == ReservationStatus.checkedOut) &&
              r.endDate.isBefore(now))
          .length;

      final myDonations = _dataService.donations
          .where((d) => d.donor.email == user.email)
          .toList();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Activity & Stats',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Active rentals', value: '$active'),
              _InfoRow(label: 'Completed rentals', value: '$past'),
              _InfoRow(label: 'Overdue rentals', value: '$overdue'),
              _InfoRow(
                  label: 'Donations made', value: '${myDonations.length}'),
            ],
          ),
        ),
      );
    }

    if (user.role == UserRole.guest) {
      final myDonations = _dataService.donations
          .where((d) => d.donor.email == user.email)
          .toList();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Activity & Stats',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                  label: 'Donations submitted',
                  value: '${myDonations.length}'),
            ],
          ),
        ),
      );
    }

    // Admin
    final equipments = _dataService.equipments;
    final reservations = _dataService.reservations;
    final donations = _dataService.donations;

    final totalEquip = equipments.length;
    final available =
        equipments.where((e) => e.status == EquipmentStatus.available).length;
    final rented =
        equipments.where((e) => e.status == EquipmentStatus.rented).length;
    final maintenance = equipments
        .where((e) => e.status == EquipmentStatus.maintenance)
        .length;
    final donated =
        equipments.where((e) => e.status == EquipmentStatus.donated).length;

    final activeReservations = reservations
        .where((r) =>
            r.status == ReservationStatus.approved ||
            r.status == ReservationStatus.checkedOut)
        .length;
    final pendingReservations = reservations
        .where((r) => r.status == ReservationStatus.pending)
        .length;
    final pendingDonations = donations
        .where((d) => d.status == DonationStatus.pendingApproval)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Center Overview',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Total equipment', value: '$totalEquip'),
            _InfoRow(label: 'Available', value: '$available'),
            _InfoRow(label: 'Rented', value: '$rented'),
            _InfoRow(label: 'Under maintenance', value: '$maintenance'),
            _InfoRow(label: 'Marked as donated', value: '$donated'),
            const SizedBox(height: 8),
            _InfoRow(
                label: 'Active reservations', value: '$activeReservations'),
            _InfoRow(
                label: 'Pending reservations', value: '$pendingReservations'),
            _InfoRow(
                label: 'Pending donations', value: '$pendingDonations'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
