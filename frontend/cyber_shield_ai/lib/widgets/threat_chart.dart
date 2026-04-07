import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ThreatChart extends StatelessWidget {
  const ThreatChart({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: 40,
            color: Colors.red,
            title: "40%",
            radius: 50,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          PieChartSectionData(
            value: 30,
            color: Colors.orange,
            title: "30%",
            radius: 50,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          PieChartSectionData(
            value: 30,
            color: Colors.green,
            title: "30%",
            radius: 50,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}