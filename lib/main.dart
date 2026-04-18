import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/student_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SeminarHallBookingApp());
}

class SeminarHallBookingApp extends StatelessWidget {
  const SeminarHallBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Seminar Hall Booking System",

      //  Named Routes (important for logout)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const DashboardScreen(),
        '/student': (context) => const StudentHomeScreen(),
      },

      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
