import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String? _selectedTypeOption;
  final TextEditingController _otherTypeController = TextEditingController();
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

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
    _imageBytes = eq?.imageBytes;
    // If existing type matches one of predefined options, select it; otherwise mark as Other.
    const predefinedTypes = [
      'Wheelchair',
      'Walker',
      'Crutches',
      'Hospital Bed',
      'Oxygen Machine',
    ];
    if (predefinedTypes.contains(_type)) {
      _selectedTypeOption = _type;
    } else if (_type.isNotEmpty) {
      _selectedTypeOption = 'Other';
      _otherTypeController.text = _type;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Resolve the actual type from the dropdown + optional "Other" field.
    if (_selectedTypeOption == 'Other') {
      _type = _otherTypeController.text.trim();
    } else {
      _type = (_selectedTypeOption ?? '').trim();
    }

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
        imageBytes: _imageBytes,
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
    final idDisplay =
        isEditing ? widget.equipment!.id : 'Will be generated when saved';

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
                initialValue: idDisplay,
                decoration: const InputDecoration(
                  labelText: 'Equipment ID',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 12),
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
                    label: const Text('Select Image'),
                  ),
                  const SizedBox(width: 12),
                  if (_imageBytes != null)
                    const Text('Image selected'),
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedTypeOption,
                decoration: const InputDecoration(
                  labelText: 'Type',
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
                    value == null || value.isEmpty ? 'Please choose a type' : null,
                onChanged: (value) {
                  setState(() {
                    _selectedTypeOption = value;
                  });
                },
                onSaved: (_) {},
              ),
              Visibility(
                visible: _selectedTypeOption == 'Other',
                maintainState: true,
                maintainAnimation: true,
                maintainSize: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                ),
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
                initialValue: _status,
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
