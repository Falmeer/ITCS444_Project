import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../../services/fake_data_services.dart';

class EquipmentFormScreen extends StatefulWidget {
  final FakeDataService dataService;
  final Equipment? equipment;

  const EquipmentFormScreen({
    super.key,
    required this.dataService,
    this.equipment,
  });

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late String _description;
  late String _location;
  late String _condition;
  late String _tags;
  late int _quantity;
  double? _rentalPricePerDay;
  EquipmentStatus _status = EquipmentStatus.available;

  @override
  void initState() {
    super.initState();
    final eq = widget.equipment;
    _name = eq?.name ?? '';
    _type = eq?.type ?? '';
    _description = eq?.description ?? '';
    _location = eq?.location ?? '';
    _condition = eq?.condition ?? 'Good';
    _tags = eq != null ? eq.tags.join(', ') : '';
    _quantity = eq?.quantity ?? 1;
    _rentalPricePerDay = eq?.rentalPricePerDay;
    _status = eq?.status ?? EquipmentStatus.available;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final tagsList = _tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final equipment = Equipment(
      id: widget.equipment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name,
      type: _type,
      description: _description,
      location: _location,
      condition: _condition,
      tags: tagsList,
      status: _status,
      quantity: _quantity,
      rentalPricePerDay: _rentalPricePerDay,
      imageUrl: widget.equipment?.imageUrl,
    );

    if (widget.equipment == null) {
      widget.dataService.addEquipment(equipment);
    } else {
      widget.dataService.updateEquipment(equipment);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.equipment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Equipment' : 'Add Equipment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Type (e.g., Wheelchair)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                onSaved: (v) => _type = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (v) => _description = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _location = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _condition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _condition = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _tags,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _tags = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Enter a positive number';
                  return null;
                },
                onSaved: (v) => _quantity = int.parse(v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue:
                    _rentalPricePerDay != null ? _rentalPricePerDay.toString() : '',
                decoration: const InputDecoration(
                  labelText: 'Rental price per day (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) {
                  if (v == null || v.isEmpty) {
                    _rentalPricePerDay = null;
                  } else {
                    _rentalPricePerDay = double.tryParse(v);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EquipmentStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: EquipmentStatus.available,
                    child: Text('Available'),
                  ),
                  DropdownMenuItem(
                    value: EquipmentStatus.rented,
                    child: Text('Rented'),
                  ),
                  DropdownMenuItem(
                    value: EquipmentStatus.donated,
                    child: Text('Donated'),
                  ),
                  DropdownMenuItem(
                    value: EquipmentStatus.maintenance,
                    child: Text('Under maintenance'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Save changes' : 'Add equipment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
