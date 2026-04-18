// lib/services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // -------------------------------------------------------------
  // CREATE BOOKING (Admin or Student)
  // -------------------------------------------------------------
  Future<String?> createBooking({
    required String department,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return "User not logged in";

      await _db.collection("bookings").add({
        "department": department,
        "date": Timestamp.fromDate(date),
        "startTime": startTime,
        "endTime": endTime,
        "status": "pending",
        "studentUid": uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------------------------------------------------
  // GET ALL BOOKINGS (Admin)
  // -------------------------------------------------------------
  Stream<List<BookingModel>> getAllBookings() {
    return _db
        .collection("bookings")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => BookingModel.fromMap(doc.id, doc.data())).toList());
  }

  // -------------------------------------------------------------
// APPROVE BOOKING (Admin) — Prevent Double Booking + 30 MIN GAP
// -------------------------------------------------------------
  Future<String?> approveBooking(String bookingId) async {
    try {
      final bookingDoc = await _db.collection("bookings").doc(bookingId).get();
      if (!bookingDoc.exists) return "Booking does not exist";

      final data = bookingDoc.data()!;
      final DateTime date = (data["date"] as Timestamp).toDate();
      final String start = data["startTime"];
      final String end = data["endTime"];

      int startMinutes = _convertToMinutes(start);
      int endMinutes = _convertToMinutes(end);

      // Fetch all approved bookings on same date
      final existingBookings = await _db
          .collection("bookings")
          .where("date", isEqualTo: Timestamp.fromDate(date))
          .where("status", isEqualTo: "approved")
          .get();

      for (var doc in existingBookings.docs) {
        final other = doc.data();
        int otherStart = _convertToMinutes(other["startTime"]);
        int otherEnd = _convertToMinutes(other["endTime"]);

        // ----------------------------------------------------
        // 1. NORMAL OVERLAP CHECK (existing rule)
        // ----------------------------------------------------
        bool overlap = !(endMinutes <= otherStart || startMinutes >= otherEnd);
        if (overlap) {
          return "This booking conflicts with another approved booking.";
        }

        // ----------------------------------------------------
        // 2. NEW RULE → 30-MINUTE GAP REQUIRED
        // ----------------------------------------------------
        // Next booking must start at least 30 min after previous ends
        if (startMinutes < otherEnd + 30 && startMinutes >= otherEnd) {
          return "A 30-minute gap is required AFTER the previous booking.";
        }

        // Previous booking must end at least 30 min before next starts
        if (endMinutes > otherStart - 30 && endMinutes <= otherStart) {
          return "A 30-minute gap is required BEFORE the next booking.";
        }
      }

      // If all good → approve booking
      await _db.collection("bookings").doc(bookingId).update({
        "status": "approved",
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Helper: Convert "10:30 AM" to minutes
  int _convertToMinutes(String timeString) {
    List parts = timeString.split(" ");
    String hourMin = parts[0];
    String period = parts[1];

    int hour = int.parse(hourMin.split(":")[0]);
    int minute = int.parse(hourMin.split(":")[1]);

    if (period == "PM" && hour != 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return hour * 60 + minute;
  }

  // -------------------------------------------------------------
  // REJECT BOOKING (Admin)
  // -------------------------------------------------------------
  Future<String?> rejectBooking(String bookingId) async {
    try {
      await _db.collection("bookings").doc(bookingId).update({
        "status": "rejected",
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------------------------------------------------
  // DELETE BOOKING (Admin)
  // -------------------------------------------------------------
  Future<String?> deleteBooking(String bookingId) async {
    try {
      await _db.collection("bookings").doc(bookingId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------------------------------------------------
  // UPDATE BOOKING (Admin Edit)
  // -------------------------------------------------------------
  Future<String?> updateBooking({
    required String bookingId,
    required String department,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await _db.collection("bookings").doc(bookingId).update({
        "department": department,
        "date": Timestamp.fromDate(date),
        "startTime": startTime,
        "endTime": endTime,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
