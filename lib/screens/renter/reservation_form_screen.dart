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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    // simple auto-duration: 3 days by default
    _endDate = _startDate.add(const Duration(days: 2));
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
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  int get _totalDays => _endDate.difference(_startDate).inDays + 1;

  bool _isAvailableForRange() {
    final existing = widget.dataService.reservations.where((r) {
      if (r.equipment.id != widget.equipment.id) return false;
      if (r.status == ReservationStatus.declined ||
          r.status == ReservationStatus.returned) {
        return false;
      }
      final overlaps = !(_endDate.isBefore(r.startDate) ||
          _startDate.isAfter(r.endDate));
      return overlaps;
    }).length;

    return existing < widget.equipment.quantity;
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
