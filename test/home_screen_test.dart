// File: test/home_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strobe_light/screens/home_screen.dart';  // Update this import to match your file structure
import 'package:strobe_light/bloc/strobe_bloc.dart';

void main() {
  testWidgets('HomeScreen has a title and a button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => StrobeBloc(
            toggleTorch: (bool isOn) {},
            rapidToggle: (Duration interval) {},
            stopRapidToggle: () {},
          ),
          child: const HomeScreen(),  // Make sure this matches your actual class name
        ),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('Strobe Light Control'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    // Tap the button and trigger a frame.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that the button text changed.
    expect(find.text('Turn Off'), findsOneWidget);
  });
}