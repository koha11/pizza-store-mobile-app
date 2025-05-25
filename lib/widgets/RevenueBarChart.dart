import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';

class RevenueBarChart extends StatelessWidget {
  final Map<int, int> revenueByDay;

  RevenueBarChart({Key? key, required this.revenueByDay}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${value.toInt()}',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  "${formatShortCurrency(value.toInt())}",
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            revenueByDay.entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble(),
                    width: 20,
                    borderRadius: BorderRadius.circular(0),
                    color: Colors.blue,
                  ),
                ],
              );
            }).toList(),
        gridData: FlGridData(show: false),
        maxY: (revenueByDay.values.reduce((a, b) => a > b ? a : b)) + 50,
      ),
    );
  }
}
