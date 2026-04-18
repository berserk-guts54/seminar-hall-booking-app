import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentBookingsScreen extends StatelessWidget {
  const StudentBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: Colors.deepPurple,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .where("studentUid", isEqualTo: uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("You have no bookings yet."),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data["date"] as Timestamp).toDate();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    data["department"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Date: ${date.day}-${date.month}-${date.year}\n"
                        "Time: ${data['startTime']} - ${data['endTime']}\n"
                        "Status: ${data['status']}",
                  ),
                  trailing: Text(
                    data["status"].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: data["status"] == "approved"
                          ? Colors.green
                          : (data["status"] == "pending"
                          ? Colors.orange
                          : Colors.red),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
