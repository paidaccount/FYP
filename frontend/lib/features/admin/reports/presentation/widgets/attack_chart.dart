import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class AttackChart extends StatelessWidget {
  const AttackChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 8.0),
        child: BarChart(
          BarChartData(
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
                  reservedSize: 26,
                  getTitlesWidget: (value, meta) {
                    String title = '';
                    switch (value.toInt()) {
                      case 0:
                        title = 'Position';
                        break;
                      case 1:
                        title = 'Speed';
                        break;
                      case 2:
                        title = 'Sybil';
                        break;
                      case 3:
                        title = 'DoS / Flood';
                        break;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: AppTheme.textSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 2,
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
            barGroups: [
              _buildBarGroup(0, 8, AppTheme.error),
              _buildBarGroup(1, 5, AppTheme.warning),
              _buildBarGroup(2, 3, AppTheme.primary),
              _buildBarGroup(3, 2, const Color(0xFF6B7280)),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        )
      ],
    );
  }
}
