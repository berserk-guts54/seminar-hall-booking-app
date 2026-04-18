// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  /// Map<Date, List<Map>>
  Map<DateTime, List<Map<String, dynamic>>> events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// Fetch all approved + pending bookings
  Future<void> _loadEvents() async {
    FirebaseFirestore.instance.collection("bookings").snapshots().listen((snap) {
      Map<DateTime, List<Map<String, dynamic>>> temp = {};

      for (var doc in snap.docs) {
        final data = doc.data();

        // Ignore rejected bookings
        if (data["status"] == "rejected") continue;

        DateTime date = (data["date"] as Timestamp).toDate();
        DateTime onlyDate = DateTime(date.year, date.month, date.day);

        temp.putIfAbsent(onlyDate, () => []);
        temp[onlyDate]!.add({
          "department": data["department"],
          "startTime": data["startTime"],
          "endTime": data["endTime"],
          "status": data["status"],
        });
      }

      setState(() => events = temp);
    });
  }

  /// Return bookings for a date
  List<Map<String, dynamic>> _getBookingsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  /// Dot color based on status
  Color _getStatusColor(String status) {
    if (status == "approved") return Colors.green;
    if (status == "pending") return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seminar Hall Calendar"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Column(
        children: [
          /// 📅 CLEAN CALENDAR (FIXED)
          TableCalendar(
            firstDay: DateTime(2023),
            lastDay: DateTime(2100),
            focusedDay: focusedDay,

            // ✅ FIX: Only month view
            calendarFormat: CalendarFormat.month,

            // ✅ FIX: Remove "2 weeks" & others
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },

            selectedDayPredicate: (day) =>
                isSameDay(selectedDay, day),

            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },

            // ❌ Disable format change
            onFormatChanged: (format) {},

            /// Show events
            eventLoader: (day) => _getBookingsForDay(day),

            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),

            /// Dots
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, eventsForDay) {
                if (eventsForDay.isEmpty) return const SizedBox();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    eventsForDay.length,
                        (index) {
                      final event =
                      eventsForDay[index] as Map<String, dynamic>;
                      final String status = event["status"];

                      return Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          /// 📋 BOOKINGS LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _getBookingsForDay(selectedDay)
                  .map(
                    (booking) => Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      Icons.event,
                      color: _getStatusColor(booking["status"]),
                    ),
                    title: Text(booking["department"]),
                    subtitle: Text(
                      "${booking['startTime']} - ${booking['endTime']}\n"
                          "Status: ${booking['status']}",
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}