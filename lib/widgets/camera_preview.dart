import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/strobe_bloc.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({Key? key}) : super(key: key);

  @override
  CameraPreviewWidgetState createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    print('CameraPreviewWidget initState');
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    print('Initializing camera');
    final cameras = await availableCameras();
    print('Available cameras: ${cameras.length}');
    final firstCamera = cameras.first;

    if (await Permission.camera.request().isGranted) {
      print('Camera permission granted');
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
      print('Camera initialized');
    } else {
      print('Camera permission denied');
    }
  }

  Future<void> toggleTorch(bool isOn) async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        print('Attempting to toggle torch: ${isOn ? 'ON' : 'OFF'}');
        await _controller!.setFlashMode(isOn ? FlashMode.torch : FlashMode.off);
        print('Torch ${isOn ? 'enabled' : 'disabled'} successfully');
      } catch (e) {
        print('Failed to ${isOn ? 'enable' : 'disable'} torch: $e');
      }
    } else {
      print('Camera controller not initialized, cannot toggle torch');
    }
  }

  @override
  void dispose() {
    print('Disposing CameraPreviewWidget');
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building CameraPreviewWidget');
    return BlocConsumer<StrobeBloc, StrobeState>(
      listenWhen: (previous, current) => previous.torchOn != current.torchOn,
      listener: (context, state) {
        print('StrobeBloc state changed, torchOn: ${state.torchOn}');
        toggleTorch(state.torchOn);
      },
      builder: (context, state) {
        return FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _controller != null && _controller!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              )
                  : const Center(child: Text('Failed to initialize camera'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}