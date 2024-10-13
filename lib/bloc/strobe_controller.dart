import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'android_flash_controller.dart';
import 'strobe_consistency_logger.dart';

class StrobeController extends ChangeNotifier {
  double _frequency = 1.0;
  bool _isStrobing = false;
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  final StrobeConsistencyLogger _logger = StrobeConsistencyLogger();
  final AndroidFlashController _flashController = AndroidFlashController();

  StrobeController();

  double get frequency => _frequency;
  bool get isStrobing => _isStrobing;
  StrobeConsistencyLogger get logger => _logger;

  void setFrequency(double newFrequency) {
    if (_frequency != newFrequency) {
      _frequency = newFrequency;
      if (_isStrobing) {
        _sendPort?.send(_frequency);
      }
      notifyListeners();
    }
  }

  void startStrobe() {
    if (!_isStrobing) {
      _isStrobing = true;
      _startIsolate();
      print("Strobe effect started");
      notifyListeners();
    }
  }

  void stopStrobe() {
    if (_isStrobing) {
      _isStrobing = false;
      _stopIsolate();
      _flashController.toggleFlash(); // Ensure flash is off
      print("Strobe effect stopped");
      notifyListeners();
    }
  }

  void _startIsolate() {
    _receivePort = ReceivePort();
    Isolate.spawn(_strobeIsolate, _receivePort!.sendPort).then((isolate) {
      _isolate = isolate;
      _receivePort!.listen((message) {
        if (message is SendPort) {
          _sendPort = message;
          _sendPort!.send(_frequency);
        } else if (message is bool) {
          _toggleFlash(message);
        }
      });
    });
  }

  void _stopIsolate() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
  }

  static void _strobeIsolate(SendPort sendPort) {
    double frequency = 1.0;
    Timer? timer;
    bool isOn = false;
    final receivePort = ReceivePort();

    sendPort.send(receivePort.sendPort);

    void startStrobe() {
      timer?.cancel();
      final intervalMicros = (500000 / frequency).round();
      timer = Timer.periodic(Duration(microseconds: intervalMicros), (_) {
        isOn = !isOn;
        sendPort.send(isOn);
      });
    }

    receivePort.listen((message) {
      if (message is double) {
        frequency = message;
        startStrobe();
      }
    });
  }

  void _toggleFlash(bool on) {
    _flashController.toggleFlash();
    _logger.logFlash();
  }

  @override
  void dispose() {
    stopStrobe();
    _flashController.dispose();
    super.dispose();
  }
}