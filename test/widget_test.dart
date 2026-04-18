import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seminar_hall_booking_app/main.dart';


void main() {
  testWidgets('Counter increments when button is pressed', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const SeminarHallBookingApp());

    // Verify initial counter is 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the increment button
    await tester.tap(find.text('Increment Counter'));
    await tester.pump();

    // Verify counter incremented
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
