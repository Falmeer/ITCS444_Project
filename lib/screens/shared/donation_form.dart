import 'package:flutter/material.dart';

import '../../models/donation.dart';
import '../../models/user.dart';
import '../../services/fake_data_services.dart';

class DonationForm extends StatefulWidget {
  final User user;
  final FakeDataService dataService;

  const DonationForm({
    super.key,
    required this.user,
    required this.dataService,
  });

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  String _itemType = '';
  String _condition = 'Good';
  String _description = '';

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final donation = Donation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      donor: widget.user,
      itemType: _itemType,
      condition: _condition,
      description: _description,
      imageUrl: null,
      status: DonationStatus.pendingApproval,
      createdAt: DateTime.now(),
    );

    widget.dataService.addDonation(donation);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Donation submitted for review')), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donate Equipment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Item type (e.g., Wheelchair)',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
              onSaved: (value) => _itemType = value!.trim(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Excellent', child: Text('Excellent')),
                DropdownMenuItem(value: 'Very Good', child: Text('Very Good')),
                DropdownMenuItem(value: 'Good', child: Text('Good')),
                DropdownMenuItem(value: 'Fair', child: Text('Fair')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _condition = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSaved: (value) => _description = value!.trim(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Submit Donation'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your donation will be reviewed by an administrator before being added to the inventory.',
            ),
          ],
        ),
      ),
    );
  }
}
