import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../bloc/strobe_controller.dart';

class CameraPreviewWidget extends StatefulWidget {
  final StrobeController strobeController;

  const CameraPreviewWidget({Key? key, required this.strobeController}) : super(key: key);

  @override
  CameraPreviewWidgetState createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.strobeController.cameraController != null &&
              widget.strobeController.cameraController!.value.isInitialized
              ? CameraPreview(widget.strobeController.cameraController!)
              : const Center(child: CircularProgressIndicator()),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (widget.strobeController.isStrobing) {
                    widget.strobeController.stopStrobe();
                  } else {
                    widget.strobeController.startStrobe();
                  }
                  setState(() {});
                },
                child: Text(widget.strobeController.isStrobing ? 'Stop Strobe' : 'Start Strobe'),
              ),
              const SizedBox(height: 16),
              Slider(
                value: widget.strobeController.frequency,
                min: 1.0,
                max: 20.0,
                divisions: 190,
                label: widget.strobeController.frequency.toStringAsFixed(1),
                onChanged: (double value) {
                  widget.strobeController.setFrequency(value);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}