import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String department;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final String studentUid;

  BookingModel({
    required this.id,
    required this.department,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.studentUid,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> data) {
    return BookingModel(
      id: id,
      department: data['department'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: data['status'] ?? 'pending',
      studentUid: data['studentUid'] ?? '',
    );
  }
}
