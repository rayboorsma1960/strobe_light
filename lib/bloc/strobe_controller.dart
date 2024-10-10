import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

class StrobeController extends ChangeNotifier {
  double _frequency = 1.0;
  bool _isStrobing = false;
  CameraController? _cameraController;
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;

  StrobeController();

  double get frequency => _frequency;
  bool get isStrobing => _isStrobing;
  CameraController? get cameraController => _cameraController;

  Future<void> initializeCamera(CameraDescription camera) async {
    print("Initializing camera: ${camera.name}");
    _cameraController = CameraController(camera, ResolutionPreset.medium);
    try {
      await _cameraController!.initialize();
      print("Camera initialized successfully");
      notifyListeners();
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

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
      _turnOffTorch();
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
      final intervalMs = (500 / frequency).round();
      timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
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
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        _cameraController!.setFlashMode(on ? FlashMode.torch : FlashMode.off);
        print("Flash mode set to: ${on ? 'torch' : 'off'}");
      } catch (e) {
        print("Error setting flash mode: $e");
      }
    } else {
      print("Camera controller not initialized");
    }
  }

  void _turnOffTorch() {
    _toggleFlash(false);
  }

  @override
  void dispose() {
    stopStrobe();
    _cameraController?.dispose();
    super.dispose();
  }
}