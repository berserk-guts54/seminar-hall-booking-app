// lib/screens/edit_booking_screen.dart
import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';

class EditBookingScreen extends StatefulWidget {
  final BookingModel booking;

  const EditBookingScreen({super.key, required this.booking});

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final BookingService _service = BookingService();

  late String department;
  late DateTime date;
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  bool loading = false;

  final List<String> departments = [
    'Agriculture', 'Architecture', 'Commerce', 'Economics', 'Management',
    'Computer Science Engineering', 'Computer Applications',
    'Electronics and Communication', 'Robotics and Automation',
    'English', 'History', 'International Languages', 'Law',
    'Fine Arts and Design', 'Mass Communication', 'Chemistry',
    'Mathematics', 'Physics', 'Statistics', 'SNU Nursing Institute',
    'Allied Health Sciences', 'Nutrition', 'Biotechnology',
    'Microbiology', 'Psychology', 'Pharmacy', 'Political Science',
    'Sociology', 'Performing Arts',
    'Centre for Corporate and Career Advancement'
  ];

  @override
  void initState() {
    super.initState();
    department = widget.booking.department;
    date = widget.booking.date;

    startTime = _parse(widget.booking.startTime);
    endTime = _parse(widget.booking.endTime);
  }

  TimeOfDay _parse(String time) {
    final parts = time.split(" ");
    final hm = parts[0].split(":");

    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);
    String period = parts[1];

    if (period == "PM" && hour != 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> saveChanges() async {
    setState(() => loading = true);

    final err = await _service.updateBooking(
      bookingId: widget.booking.id,
      department: department,
      date: date,
      startTime: startTime.format(context),
      endTime: endTime.format(context),
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking updated successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $err")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Booking"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// FIXED DROPDOWN — Prevents Right Overflow
              DropdownButtonFormField<String>(
                value: department,
                isExpanded: true, // ensures safe width
                items: departments.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        d,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => department = v!),
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                title: Text("Date: ${date.day}-${date.month}-${date.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => date = picked);
                },
              ),

              ListTile(
                title: Text("Start: ${startTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) setState(() => startTime = picked);
                },
              ),

              ListTile(
                title: Text("End: ${endTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) setState(() => endTime = picked);
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: loading ? null : saveChanges,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
