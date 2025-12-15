import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String? _selectedTypeOption;
  final TextEditingController _otherTypeController = TextEditingController();
  String _condition = 'Good';
  String _description = '';
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Resolve the actual item type from dropdown + optional "Other" text.
    String itemType;
    if (_selectedTypeOption == 'Other') {
      itemType = _otherTypeController.text.trim();
    } else {
      itemType = (_selectedTypeOption ?? '').trim();
    }

    final donation = Donation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      donor: widget.user,
      itemType: itemType,
      condition: _condition,
      description: _description,
      imageUrl: null,
      imageBytes: _imageBytes,
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
            DropdownButtonFormField<String>(
              initialValue: _selectedTypeOption,
              decoration: const InputDecoration(
                labelText: 'Item type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Wheelchair',
                  child: Text('Wheelchair'),
                ),
                DropdownMenuItem(
                  value: 'Walker',
                  child: Text('Walker'),
                ),
                DropdownMenuItem(
                  value: 'Crutches',
                  child: Text('Crutches'),
                ),
                DropdownMenuItem(
                  value: 'Cane',
                  child: Text('Cane'),
                ),
                DropdownMenuItem(
                  value: 'Shower Chair',
                  child: Text('Shower Chair'),
                ),
                DropdownMenuItem(
                  value: 'Commode',
                  child: Text('Commode'),
                ),
                DropdownMenuItem(
                  value: 'Hospital Bed',
                  child: Text('Hospital Bed'),
                ),
                DropdownMenuItem(
                  value: 'Oxygen Machine',
                  child: Text('Oxygen Machine'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please choose a type' : null,
              onChanged: (value) {
                setState(() => _selectedTypeOption = value);
              },
            ),
            if (_selectedTypeOption == 'Other') ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _otherTypeController,
                decoration: const InputDecoration(
                  labelText: 'Other type',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (_selectedTypeOption == 'Other') {
                    if (v == null || v.isEmpty) {
                      return 'Please specify the type';
                    }
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
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
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                    );
                    if (picked != null) {
                      final bytes = await picked.readAsBytes();
                      setState(() {
                        _imageBytes = bytes;
                      });
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Select Photo (optional)'),
                ),
                const SizedBox(width: 12),
                if (_imageBytes != null)
                  const Text('Photo selected'),
              ],
            ),
            const SizedBox(height: 8),
            if (_imageBytes != null)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
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
