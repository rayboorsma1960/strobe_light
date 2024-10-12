import 'package:flutter/material.dart';
import '../bloc/strobe_controller.dart';
import '../widgets/strobe_analysis_widget.dart'; // Add this import
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StrobeController _strobeController;
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    _strobeController = StrobeController();
  }

  void _toggleLogging() {
    setState(() {
      _isLogging = !_isLogging;
      if (_isLogging) {
        _strobeController.logger.startLogging();
      } else {
        final analysis = _strobeController.logger.stopLoggingAndAnalyze();
        _showAnalysisDialog(analysis);
      }
    });
  }

  void _showAnalysisDialog(Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: StrobeAnalysisWidget(analysis: analysis),
          ),
        );
      },
    );
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_strobeController.isStrobing) {
                    _strobeController.stopStrobe();
                  } else {
                    _strobeController.startStrobe();
                  }
                  setState(() {});
                },
                child: Text(_strobeController.isStrobing ? 'Stop Strobe' : 'Start Strobe'),
              ),
              SizedBox(height: 16),
              Slider(
                value: _strobeController.frequency,
                min: 1.0,
                max: 20.0,
                divisions: 190,
                label: _strobeController.frequency.toStringAsFixed(1),
                onChanged: (value) {
                  _strobeController.setFrequency(value);
                  setState(() {});
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _toggleLogging,
                child: Text(_isLogging ? 'Stop Logging' : 'Start Logging'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}