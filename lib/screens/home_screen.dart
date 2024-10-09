import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/strobe_bloc.dart';
import '../widgets/strobe_light.dart';
import '../widgets/frequency_slider.dart';
import '../widgets/camera_preview.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Strobe Light')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: CameraPreviewWidget(),
            ),
            Expanded(
              flex: 3,
              child: BlocBuilder<StrobeBloc, StrobeState>(
                builder: (context, state) {
                  return ListView(
                    padding: EdgeInsets.all(16.0),
                    children: <Widget>[
                      StrobeLight(),
                      SizedBox(height: 20),
                      Text(
                        'Frequency: ${state.frequency.toStringAsFixed(1)} Hz',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'RPM: ${(state.frequency * 60).toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      FrequencySlider(),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          child: Text(state.isOn ? 'Turn Off' : 'Turn On'),
                          onPressed: () {
                            context.read<StrobeBloc>().add(ToggleStrobe());
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}