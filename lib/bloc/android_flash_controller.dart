import 'package:torch_light/torch_light.dart';

class AndroidFlashController {
  bool _isFlashOn = false;

  Future<void> toggleFlash() async {
    try {
      if (_isFlashOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      _isFlashOn = !_isFlashOn;
    //  print("Flash toggled successfully. Is on: $_isFlashOn");
    } catch (e) {
    //  print("Failed to toggle flash: $e");
    }
  }

  Future<void> dispose() async {
    if (_isFlashOn) {
      await TorchLight.disableTorch();
    }
  }
}