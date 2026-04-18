// lib/screens/booking_form_screen.dart
import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final BookingService bookingService = BookingService();

  final List<String> departments =[
    // School of Arts, Media & design
    'Design', 'Fine Arts', 'Journalism & Mass Communication', 'Performing Arts',

    // School of Humanities, Languages and Social Sciences
    'English', 'History', 'International Languages', 'Political Science', 'Sociology',

    // School of Law, Business & Governance
    'Commerce', 'Economics', 'Law', 'Management',

    // School of Life, Agricultural & Biotechnological Sciences
    'Agriculture', 'Biotechnology', 'Microbiology', 'Nutrition',

    // School of Nursing, Health & Pharmaceutical Sciences
    'Allied Health Sciences', 'Nursing', 'Pharmacy',

    // School of Science & Technology
    'Architecture and Planning', 'Chemistry', 'Computer Science & Applications',
    'Computer Science Engineering', 'Electronics and Communication Engineering',
    'Mathematics', 'Physics', 'Psychology', 'Statistics', 'Town Planning',

    // School of Lifelong Learning
    'Hospitality and Tourism',
  ];

  String? selectedDepartment;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool isLoading = false;

  // Format TimeOfDay → "6:30 PM"
  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, "0");
    final period = t.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  // VALIDATION
  String? validateForm() {
    if (selectedDepartment == null) return "Select a department.";
    if (selectedDate == null) return "Select a date.";
    if (startTime == null) return "Select a start time.";
    if (endTime == null) return "Select an end time.";

    // date cannot be past
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (selectedDate!.isBefore(today)) {
      return "Date cannot be in the past.";
    }

    // convert times to minutes
    int startM = startTime!.hour * 60 + startTime!.minute;
    int endM = endTime!.hour * 60 + endTime!.minute;

    if (endM <= startM) {
      return "End time must be later than start time.";
    }

    // minimum duration 30 minutes
    if ((endM - startM) < 30) {
      return "Minimum booking duration is 30 minutes.";
    }

    return null; // all good
  }

  // SUBMIT
  Future<void> submitBooking() async {
    final validationMsg = validateForm();
    if (validationMsg != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(validationMsg)));
      return;
    }

    setState(() => isLoading = true);

    final err = await bookingService.createBooking(
      department: selectedDepartment!,
      date: selectedDate!,
      startTime: _formatTime(startTime!),
      endTime: _formatTime(endTime!),
    );

    setState(() => isLoading = false);

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking submitted for admin approval")),
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
        title: const Text("Create Booking"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Department
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
                items: departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => selectedDepartment = v),
              ),
              const SizedBox(height: 16),

              // Date
              ListTile(
                title: Text(selectedDate == null
                    ? "Select Date"
                    : "Date: ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
              const SizedBox(height: 16),

              // Start Time
              ListTile(
                title: Text(startTime == null
                    ? "Select Start Time"
                    : "Start: ${_formatTime(startTime!)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) setState(() => startTime = t);
                },
              ),
              const SizedBox(height: 16),

              // End Time
              ListTile(
                title: Text(endTime == null
                    ? "Select End Time"
                    : "End: ${_formatTime(endTime!)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) setState(() => endTime = t);
                },
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: isLoading ? null : submitBooking,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Booking"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
