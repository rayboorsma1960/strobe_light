import 'dart:async'; // Add this import for Timer
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/strobe_bloc.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({super.key}); // Changed to use super parameter

  @override
  CameraPreviewWidgetState createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isTorchOn = false;
  Timer? _strobeTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    if (await Permission.camera.request().isGranted) {
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> toggleTorch(bool isOn) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      if (isOn != _isTorchOn) {
        await _controller!.setFlashMode(isOn ? FlashMode.torch : FlashMode.off);
        _isTorchOn = isOn;
      }
    } catch (e) {
      // Use a proper logging mechanism instead of print in production
      debugPrint('Failed to toggle torch: $e');
    }
  }

  void rapidToggle(Duration interval) {
    _strobeTimer?.cancel();
    _strobeTimer = Timer.periodic(interval, (timer) {
      toggleTorch(!_isTorchOn);
    });
  }

  void stopRapidToggle() {
    _strobeTimer?.cancel();
    _strobeTimer = null;
  }

  @override
  void dispose() {
    stopRapidToggle();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StrobeBloc(
        toggleTorch: toggleTorch,
        rapidToggle: rapidToggle,
        stopRapidToggle: stopRapidToggle,
      ),
      child: BlocBuilder<StrobeBloc, StrobeState>(
        builder: (context, state) {
          return FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _controller != null && _controller!.value.isInitialized
                    ? Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Text(
                        'Strobe: ${state.isOn ? 'ON' : 'OFF'}',
                        style: const TextStyle(color: Colors.white, backgroundColor: Colors.black54),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        children: [
                          Text(
                            'Frequency: ${state.frequency.toStringAsFixed(1)} Hz',
                            style: const TextStyle(color: Colors.white, backgroundColor: Colors.black54),
                          ),
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
                          ElevatedButton(
                            onPressed: () {
                              context.read<StrobeBloc>().add(ToggleStrobe());
                            },
                            child: Text(state.isOn ? 'Stop Strobe' : 'Start Strobe'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    : const Center(child: Text('Failed to initialize camera'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
}