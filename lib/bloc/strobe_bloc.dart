import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

abstract class StrobeEvent {}

class ToggleStrobe extends StrobeEvent {}

class ChangeFrequency extends StrobeEvent {
  final double frequency;
  ChangeFrequency(this.frequency);
}

class StrobeState {
  final bool isOn;
  final double frequency;
  final bool torchOn;

  const StrobeState({required this.isOn, required this.frequency, required this.torchOn});

  StrobeState copyWith({bool? isOn, double? frequency, bool? torchOn}) {
    return StrobeState(
      isOn: isOn ?? this.isOn,
      frequency: frequency ?? this.frequency,
      torchOn: torchOn ?? this.torchOn,
    );
  }
}

class StrobeBloc extends Bloc<StrobeEvent, StrobeState> {
  final Function(bool) toggleTorch;
  final Function(Duration) rapidToggle;
  final Function() stopRapidToggle;
  Timer? _strobeTimer;

  StrobeBloc({
    required this.toggleTorch,
    required this.rapidToggle,
    required this.stopRapidToggle,
  }) : super(const StrobeState(isOn: false, frequency: 1.0, torchOn: false)) {
    on<ToggleStrobe>((event, emit) async {
      final newIsOn = !state.isOn;
      if (newIsOn) {
        _startStrobeEffect();
      } else {
        _stopStrobeEffect();
      }
      emit(state.copyWith(isOn: newIsOn));
    });

    on<ChangeFrequency>((event, emit) {
      emit(state.copyWith(frequency: event.frequency));
      if (state.isOn) {
        _updateStrobeFrequency();
      }
    });
  }

  void _startStrobeEffect() {
    final interval = Duration(milliseconds: (500 / state.frequency).round());
    rapidToggle(interval);
  }

  void _stopStrobeEffect() {
    stopRapidToggle();
    toggleTorch(false);
  }

  void _updateStrobeFrequency() {
    _stopStrobeEffect();
    _startStrobeEffect();
  }

  @override
  Future<void> close() {
    _strobeTimer?.cancel();
    return super.close();
  }
}