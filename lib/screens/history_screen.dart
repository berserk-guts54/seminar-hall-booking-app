import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import 'edit_booking_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  String searchQuery = "";
  String selectedFilter = "all";

  Color getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Column(
        children: [

          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search department...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          // 🎯 FILTER
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                buildChip("all"),
                buildChip("pending"),
                buildChip("approved"),
                buildChip("rejected"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 📋 LIST
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: bookingService.getAllBookings(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data!;

                final filtered = bookings.where((b) {
                  final matchSearch = searchQuery.isEmpty
                      ? true
                      : b.department.toLowerCase().contains(searchQuery);

                  final matchFilter = selectedFilter == "all"
                      ? true
                      : b.status.toLowerCase() == selectedFilter;

                  return matchSearch && matchFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No bookings found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final b = filtered[i];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(b.department),
                        subtitle: Text(
                          "📅 ${b.date.day}-${b.date.month}-${b.date.year}\n"
                              "⏰ ${b.startTime} - ${b.endTime}",
                        ),
                        trailing: Text(
                          b.status.toUpperCase(),
                          style: TextStyle(
                            color: getStatusColor(b.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditBookingScreen(booking: b),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChip(String status) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(status.toUpperCase()),
        selected: selectedFilter == status,
        onSelected: (_) {
          setState(() => selectedFilter = status);
        },
      ),
    );
  }
}