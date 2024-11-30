import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProductivityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1, // Set interval untuk sumbu kiri
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('17');
                  case 1:
                    return const Text('18');
                  case 2:
                    return const Text('19');
                  case 3:
                    return const Text('20');
                  case 4:
                    return const Text('21');
                  case 5:
                    return const Text('22');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: 2,
              color: Colors.blueAccent,
              width: 16,
            ),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              toY: 1,
              color: Colors.blueAccent,
              width: 16,
            ),
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
              toY: 4,
              color: Colors.blueAccent,
              width: 16,
            ),
          ]),
          BarChartGroupData(x: 3, barRods: [
            BarChartRodData(
              toY: 3,
              color: Colors.blueAccent,
              width: 16,
            ),
          ]),
          BarChartGroupData(x: 4, barRods: [
            BarChartRodData(
              toY: 2,
              color: Colors.blueAccent,
              width: 16,
            ),
          ]),
          BarChartGroupData(x: 5, barRods: [
            BarChartRodData(
              toY: 1,
              color: Colors.blueAccent,
              width: 16,
            ),
          ]),
        ],
      ),
    );
  }
}
