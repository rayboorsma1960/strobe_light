import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/strobe_bloc.dart';

class StrobeLight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrobeBloc, StrobeState>(
      builder: (context, state) {
        print('StrobeLight rebuilding. isOn: ${state.isOn}, frequency: ${state.frequency}');
        return AnimatedContainer(
          duration: Duration(milliseconds: (500 / state.frequency).round()),
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.isOn ? Colors.white : Colors.black,
          ),
          child: Center(
            child: Text(
              state.isOn ? 'ON' : 'OFF',
              style: TextStyle(
                color: state.isOn ? Colors.black : Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}