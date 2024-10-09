import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/strobe_bloc.dart';

class FrequencySlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrobeBloc, StrobeState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Frequency: ${state.frequency.toStringAsFixed(1)} Hz'),
            SizedBox(height: 8),
            Slider(
              value: state.frequency,
              min: 1.0,
              max: 20.0,
              divisions: 38,
              label: state.frequency.toStringAsFixed(1),
              onChanged: (double value) {
                context.read<StrobeBloc>().add(ChangeFrequency(value));
              },
            ),
          ],
        );
      },
    );
  }
}