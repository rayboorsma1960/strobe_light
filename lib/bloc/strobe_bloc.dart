import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:isolate';

abstract class StrobeEvent {}

class ToggleStrobe extends StrobeEvent {}

class ChangeFrequency extends StrobeEvent {
  final double frequency;
  ChangeFrequency(this.frequency);
}

class UpdateTorch extends StrobeEvent {
  final bool isOn;
  UpdateTorch(this.isOn);
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
  Isolate? _strobeIsolate;
  final ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPort;
  StreamSubscription? _receivePortSubscription;

  StrobeBloc() : super(const StrobeState(isOn: false, frequency: 1.0, torchOn: false)) {
    _initializeIsolate();

    on<ToggleStrobe>((event, emit) async {
      print('ToggleStrobe event received. Current state: ${state.isOn}');
      final newIsOn = !state.isOn;
      if (newIsOn) {
        _startStrobeEffect();
      } else {
        _stopStrobeEffect();
      }
      emit(state.copyWith(isOn: newIsOn));
      print('ToggleStrobe event processed. New state: ${state.isOn}');
    });

    on<ChangeFrequency>((event, emit) {
      print('ChangeFrequency event received. New frequency: ${event.frequency}');
      emit(state.copyWith(frequency: event.frequency));
      if (state.isOn) {
        _sendPort?.send({'type': 'frequency', 'value': event.frequency});
      }
    });

    on<UpdateTorch>((event, emit) {
      print('UpdateTorch event received. Torch state: ${event.isOn}');
      emit(state.copyWith(torchOn: event.isOn));
    });
  }

  void _initializeIsolate() async {
    print('Initializing isolate');
    _strobeIsolate = await Isolate.spawn(_strobeLogic, _receivePort.sendPort);
    _sendPort = await _receivePort.first as SendPort;
    _receivePortSubscription = _receivePort.listen(_handleIsolateMessage);
    print('Isolate initialized');
  }

  void _handleIsolateMessage(dynamic message) {
    print('Received message from isolate: $message');
    if (message is bool) {
      print('Updating torch state to: $message');
      add(UpdateTorch(message));
    }
  }

  void _startStrobeEffect() {
    print('Starting strobe effect with frequency: ${state.frequency}');
    _sendPort?.send({'type': 'start', 'frequency': state.frequency});
  }

  void _stopStrobeEffect() {
    print('Stopping strobe effect');
    _sendPort?.send({'type': 'stop'});
  }

  static void _strobeLogic(SendPort sendPort) {
    print('Strobe logic started in isolate');
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    double frequency = 1.0;
    bool isOn = false;
    Timer? timer;

    void startOrUpdateTimer() {
      timer?.cancel();
      final interval = Duration(microseconds: (500000 / frequency).round());
      print('Starting timer with interval: $interval');
      timer = Timer.periodic(interval, (_) {
        isOn = !isOn;
        print('Sending torch state from isolate: $isOn');
        sendPort.send(isOn);
      });
    }

    receivePort.listen((message) {
      print('Isolate received message: $message');
      if (message is Map<String, dynamic>) {
        switch (message['type']) {
          case 'start':
            frequency = message['frequency'];
            print('Starting strobe in isolate with frequency: $frequency');
            startOrUpdateTimer();
            break;
          case 'stop':
            print('Stopping strobe in isolate');
            timer?.cancel();
            timer = null;
            break;
          case 'frequency':
            frequency = message['value'];
            print('Updating frequency in isolate to: $frequency');
            if (timer != null) {
              startOrUpdateTimer();
            }
            break;
        }
      }
    });
  }

  @override
  Future<void> close() async {
    print('Closing StrobeBloc');
    await _receivePortSubscription?.cancel();
    _strobeIsolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    return super.close();
  }
}