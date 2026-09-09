import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class SecurityReportsScreen extends ConsumerStatefulWidget {
  const SecurityReportsScreen({super.key});

  @override
  ConsumerState<SecurityReportsScreen> createState() => _SecurityReportsScreenState();
}

class _SecurityReportsScreenState extends ConsumerState<SecurityReportsScreen> {
  String _selectedTimeframe = 'This Week';
  bool _isDownloading = false;

  void _handleDownload() async {
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'VANET Security & Trust Report (PDF/CSV) downloaded successfully.',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5),
          ),
          backgroundColor: AppTheme.safe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Security Reports',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Timeframe Dropdown (Matching Mockup 11)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTimeframe,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedTimeframe = newValue);
                    }
                  },
                  items: <String>['Today', 'This Week', 'This Month', 'All Time']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 🔹 4 Stat Summary Cards (2x2 Grid matching Mockup 11)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard('Malicious Vehicles', '15', AppTheme.error),
                _buildMetricCard('Fake Emergencies', '3', AppTheme.warning),
                _buildMetricCard('Total Alerts', '42', AppTheme.primary),
                _buildMetricCard('Accidents', '6', const Color(0xFF2563EB)),
              ],
            ),

            const SizedBox(height: 18),

            // 🔹 Attack Types Donut Chart Section (Matching Mockup 11)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.02),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attack Types',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Donut Chart
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: [
                              PieChartSectionData(color: const Color(0xFF10B981), value: 30, radius: 20, showTitle: false),
                              PieChartSectionData(color: const Color(0xFF3B82F6), value: 20, radius: 20, showTitle: false),
                              PieChartSectionData(color: const Color(0xFFF59E0B), value: 20, radius: 20, showTitle: false),
                              PieChartSectionData(color: const Color(0xFFEF4444), value: 15, radius: 20, showTitle: false),
                              PieChartSectionData(color: const Color(0xFF8B5CF6), value: 10, radius: 20, showTitle: false),
                              PieChartSectionData(color: const Color(0xFF9CA3AF), value: 5, radius: 20, showTitle: false),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),

                      // Donut Legend
                      Expanded(
                        child: Column(
                          children: [
                            _buildAttackLegendRow('False Position', '30%', const Color(0xFF10B981)),
                            const SizedBox(height: 5),
                            _buildAttackLegendRow('False Speed', '20%', const Color(0xFF3B82F6)),
                            const SizedBox(height: 5),
                            _buildAttackLegendRow('Sybil Attack', '20%', const Color(0xFFF59E0B)),
                            const SizedBox(height: 5),
                            _buildAttackLegendRow('Replay Attack', '15%', const Color(0xFFEF4444)),
                            const SizedBox(height: 5),
                            _buildAttackLegendRow('DoS Behavior', '10%', const Color(0xFF8B5CF6)),
                            const SizedBox(height: 5),
                            _buildAttackLegendRow('Others', '5%', const Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 🔹 Full-width Download Report Button (Matching Mockup 11)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _isDownloading ? null : _handleDownload,
                child: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Download Report',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttackLegendRow(String title, String percent, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          percent,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
