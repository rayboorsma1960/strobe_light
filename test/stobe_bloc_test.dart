// File: test/strobe_bloc_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:strobe_light/bloc/strobe_bloc.dart';  // Update this import

void main() {
  group('StrobeBloc', () {
    late StrobeBloc strobeBloc;

    setUp(() {
      strobeBloc = StrobeBloc(
        toggleTorch: (bool isOn) {},
        rapidToggle: (Duration interval) {},
        stopRapidToggle: () {},
      );
    });

    test('initial state is correct', () {
      expect(strobeBloc.state, const StrobeState(isOn: false, frequency: 1.0));
    });

    blocTest<StrobeBloc, StrobeState>(
      'emits [StrobeState(isOn: true, frequency: 1.0)] when ToggleStrobe is added',
      build: () => strobeBloc,
      act: (bloc) => bloc.add(ToggleStrobe()),
      expect: () => [const StrobeState(isOn: true, frequency: 1.0)],
    );

    blocTest<StrobeBloc, StrobeState>(
      'emits [StrobeState(isOn: false, frequency: 2.0)] when ChangeFrequency is added',
      build: () => strobeBloc,
      act: (bloc) => bloc.add(ChangeFrequency(2.0)),
      expect: () => [const StrobeState(isOn: false, frequency: 2.0)],
    );
  });
}