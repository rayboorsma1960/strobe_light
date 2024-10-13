import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class StrobeAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const StrobeAnalysisWidget({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    double averageInterval = analysis['average'];
    double frequency = 1000000 / averageInterval;
    int stabilityScore = _calculateStabilityScore(analysis['stdDev'], averageInterval);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strobe Analysis', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              [
                _buildInfoCard('Frequency', '${frequency.toStringAsFixed(1)} Hz'),
                _buildInfoCard('Stability', '$stabilityScore/10', color: _getStabilityColor(stabilityScore)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              [
                _buildInfoCard('Total Flashes', '${analysis['totalFlashes']}', icon: Icons.flash_on),
                _buildInfoCard('Duration', '${(analysis['durationMs'] / 1000).toStringAsFixed(2)} s', icon: Icons.timer),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              [
                _buildInfoCard('Max Dev', '${(analysis['maxDeviation'] / 1000).toStringAsFixed(2)} ms'),
                _buildInfoCard('Std Dev', '${(analysis['stdDev'] / 1000).toStringAsFixed(2)} ms'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Interval Distribution', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: _buildIntervalDistributionChart(analysis['intervalCounts']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, List<Widget> children) {
    return Row(
      children: children.map((child) => Expanded(child: child)).toList(),
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
            Text(title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalDistributionChart(Map<int, int> intervalCounts) {
    List<BarChartGroupData> barGroups = [];
    int maxCount = 0;
    int minInterval = intervalCounts.keys.reduce(min);
    int maxInterval = intervalCounts.keys.reduce(max);
    double averageInterval = intervalCounts.entries
        .map((e) => e.key * e.value)
        .reduce((a, b) => a + b) /
        intervalCounts.values.reduce((a, b) => a + b);

    intervalCounts.forEach((key, value) {
      maxCount = value > maxCount ? value : maxCount;
      barGroups.add(BarChartGroupData(
        x: key,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: (key - averageInterval).abs() < 1 ? Colors.green : Colors.blue,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          )
        ],
      ));
    });

    return Column(
      children: [
        Text(
          'Flash Interval Distribution',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Shows how often each interval between flashes occurred',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                  axisNameWidget: Text('Count', style: TextStyle(fontSize: 12)),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % ((maxInterval - minInterval) ~/ 5 + 1) == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                  axisNameWidget: Text('Interval (ms)', style: TextStyle(fontSize: 12)),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              maxY: maxCount.toDouble(),
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${group.x.toInt()} ms: ${rod.toY.toInt()} times',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            swapAnimationDuration: Duration.zero,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 16, height: 16, color: Colors.blue),
            SizedBox(width: 4),
            Text('Normal', style: TextStyle(fontSize: 12)),
            SizedBox(width: 16),
            Container(width: 16, height: 16, color: Colors.green),
            SizedBox(width: 4),
            Text('Average', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
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