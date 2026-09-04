import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class TrustChart extends StatelessWidget {
  final List<double> history;

  const TrustChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No trust history telemetry recorded yet',
            style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
      );
    }

    final spots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0, top: 8.0, left: 4.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: AppTheme.border,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    final label = idx < history.length ? 'T-${history.length - 1 - idx}' : '';
                    return Text(
                      label,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 25,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 9.5,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (history.length - 1).toDouble().clamp(1.0, double.infinity),
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppTheme.safe,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3.5,
                      color: AppTheme.safe,
                      strokeWidth: 1.5,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.safe.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
