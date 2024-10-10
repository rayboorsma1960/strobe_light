// File: test/camera_preview_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strobe_light/widgets/camera_preview.dart';
import 'package:strobe_light/bloc/strobe_bloc.dart';

void main() {
  testWidgets('CameraPreviewWidget displays loading indicator initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => StrobeBloc(
            toggleTorch: (bool isOn) {},
            rapidToggle: (Duration interval) {},
            stopRapidToggle: () {},
          ),
          child: const CameraPreviewWidget(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}