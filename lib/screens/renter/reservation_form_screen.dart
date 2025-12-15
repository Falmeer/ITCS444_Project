import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../../models/reservation.dart';
import '../../models/user.dart';
import '../../services/fake_data_services.dart';

class ReservationFormScreen extends StatefulWidget {
  final Equipment equipment;
  final User renter;
  final FakeDataService dataService;

  const ReservationFormScreen({
    super.key,
    required this.equipment,
    required this.renter,
    required this.dataService,
  });

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  late _DurationConfig _durationConfig;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _durationConfig = _durationConfigFor(widget.equipment);
    // Auto-suggested duration based on equipment type.
    _endDate = _startDate.add(
      Duration(days: _durationConfig.suggestedDays - 1),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Ensure end date stays within the allowed range relative to
        // the (possibly new) start date.
        final minEnd = _startDate.add(
          Duration(days: _durationConfig.minDays - 1),
        );
        final maxEnd = _startDate.add(
          Duration(days: _durationConfig.maxDays - 1),
        );

        if (_endDate.isBefore(minEnd)) {
          _endDate = minEnd;
        } else if (_endDate.isAfter(maxEnd)) {
          _endDate = maxEnd;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate.add(
        Duration(days: _durationConfig.minDays - 1),
      ),
      lastDate: _startDate.add(
        Duration(days: _durationConfig.maxDays - 1),
      ),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  int get _totalDays => _endDate.difference(_startDate).inDays + 1;

  bool _isAvailableForRange() {
    // Only basic validation here: renters are allowed to submit
    // requests even if dates overlap with others. Admin will decide
    // which requests to approve.
    return true;
  }

  _DurationConfig _durationConfigFor(Equipment equipment) {
    final type = equipment.type.toLowerCase();

    // 1. Short-term equipment: crutches, canes, walkers
    if (type.contains('crutch') ||
        type.contains('cane') ||
        type.contains('walker')) {
      return const _DurationConfig(minDays: 3, maxDays: 14, suggestedDays: 7);
    }

    // 2. Medium-term equipment: wheelchairs, shower chairs, commodes
    if (type.contains('wheelchair') ||
        type.contains('shower') ||
        type.contains('commode')) {
      return const _DurationConfig(minDays: 7, maxDays: 30, suggestedDays: 14);
    }

    // 3. Long-term / critical equipment: hospital beds, oxygen machines
    if (type.contains('bed') || type.contains('oxygen')) {
      return const _DurationConfig(minDays: 14, maxDays: 90, suggestedDays: 30);
    }

    // Fallback: treat as medium-short usage.
    return const _DurationConfig(minDays: 3, maxDays: 30, suggestedDays: 7);
  }

  void _submit() {
    if (!_isAvailableForRange()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Selected dates are not available for this equipment. Please try another range.'),
        ),
      );
      return;
    }

    final reservation = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      equipment: widget.equipment,
      renter: widget.renter,
      startDate: _startDate,
      endDate: _endDate,
      status: ReservationStatus.pending,
    );

    widget.dataService.addReservation(reservation);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation request submitted for approval')),
    );

    Navigator.of(context).popUntil((route) => route.isFirst == false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final pricePerDay = widget.equipment.rentalPricePerDay ?? 0;
    final totalPrice = pricePerDay * _totalDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve equipment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.equipment.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start date'),
              subtitle: Text('${_startDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStartDate,
            ),
            ListTile(
              title: const Text('End date'),
              subtitle: Text('${_endDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickEndDate,
            ),
            const SizedBox(height: 8),
            Text(
              'Allowed duration: ${_durationConfig.minDays}-${_durationConfig.maxDays} day(s). '
              'Suggested: ${_durationConfig.suggestedDays} day(s).',
            ),
            const SizedBox(height: 4),
            Text('Duration: $_totalDays day(s)'),
            if (pricePerDay > 0)
              Text('Estimated total: ${totalPrice.toStringAsFixed(1)} BD'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Submit reservation request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationConfig {
  final int minDays;
  final int maxDays;
  final int suggestedDays;

  const _DurationConfig({
    required this.minDays,
    required this.maxDays,
    required this.suggestedDays,
  });
}

