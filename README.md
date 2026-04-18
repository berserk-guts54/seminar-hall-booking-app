# Seminar Hall Booking App

A Flutter based mobile application developed to manage seminar hall bookings in a college environmnet. The system ensures that only authorized staff can book the hall, while students can view schedules.

## Features:
 - Role-based authentication (Admin / Student)
 - Admin-only booking system
 - 30-minute buffer between bookings
 - Calendar view of bookings
 - Booking approval and rejection system
 - Delete booking with confirmation
 - Real-time updates using Firebase Firestore
## Tech Stack:
 - Flutter (Frontend)
 - Firebase Authentication
 - Cloud Firestore (Database)
## APK Download

 Download the app from the **Releases** section of this repository.

- arm64 → Recommended for most Android phones
- armeabi-v7a → For older devices
- x86_64 → Emulator/testing

## How It Works: 
  - User logs in using Firebase Authentication
  - Role is fetched from Firestore database
  - Admin can create, approve, edit, and delete bookings
  - Students can view bookings and schedules
  - All updates reflect in real-time
