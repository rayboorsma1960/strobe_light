import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../bloc/strobe_controller.dart';
import '../widgets/camera_preview.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StrobeController _strobeController;

  @override
  void initState() {
    super.initState();
    _strobeController = StrobeController();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _strobeController.initializeCamera(widget.cameras.first);
    setState(() {});
  }

  @override
  void dispose() {
    _strobeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strobe Light')),
      body: Center(
        child: CameraPreviewWidget(strobeController: _strobeController),
      ),
    );
  }
}