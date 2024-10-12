import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StrobeAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const StrobeAnalysisWidget({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    double averageInterval = analysis['average'];
    double frequency = 1000000 / averageInterval;
    int stabilityScore = _calculateStabilityScore(analysis['stdDev'], averageInterval);

    return ListView(
      children: [
        Text('Strobe Analysis', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoCard('Frequency', '${frequency.toStringAsFixed(1)} Hz'),
            _buildInfoCard('Stability', '$stabilityScore/10', color: _getStabilityColor(stabilityScore)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoCard('Total Flashes', '${analysis['totalFlashes']}', icon: Icons.flash_on),
            _buildInfoCard('Duration', '${(analysis['durationMs'] / 1000).toStringAsFixed(2)} s', icon: Icons.timer),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoCard('Max Deviation', '${(analysis['maxDeviation'] / 1000).toStringAsFixed(2)} ms'),
            _buildInfoCard('Std Deviation', '${(analysis['stdDev'] / averageInterval * 100).toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Interval Distribution', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: _buildIntervalDistributionChart(analysis['intervalCounts']),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, {IconData? icon, Color? color}) {
    return Card(
      color: color ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (icon != null) Icon(icon, size: 24),
            Text(title, style: const TextStyle(fontSize: 14)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalDistributionChart(Map<int, int> intervalCounts) {
    List<BarChartGroupData> barGroups = [];
    intervalCounts.forEach((key, value) {
      barGroups.add(BarChartGroupData(
        x: key,
        barRods: [BarChartRodData(toY: value.toDouble())],
      ));
    });

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
      ),
    );
  }

  int _calculateStabilityScore(double stdDeviation, double average) {
    double relativeStdDev = stdDeviation / average;
    if (relativeStdDev < 0.01) return 10;
    if (relativeStdDev < 0.02) return 9;
    if (relativeStdDev < 0.03) return 8;
    if (relativeStdDev < 0.04) return 7;
    if (relativeStdDev < 0.05) return 6;
    if (relativeStdDev < 0.06) return 5;
    if (relativeStdDev < 0.07) return 4;
    if (relativeStdDev < 0.08) return 3;
    if (relativeStdDev < 0.09) return 2;
    return 1;
  }

  Color _getStabilityColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 5) return Colors.yellow;
    return Colors.red;
  }
}