import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/admin/dashboard/presentation/dashboard_provider.dart';

class AIExplanationScreen extends ConsumerStatefulWidget {
  final String id;

  const AIExplanationScreen({super.key, required this.id});

  @override
  ConsumerState<AIExplanationScreen> createState() => _AIExplanationScreenState();
}

class _AIExplanationScreenState extends ConsumerState<AIExplanationScreen> {
  bool _showDeepDetails = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final explanation = state.explanations[widget.id];

    final isMalicious = explanation?.prediction.toLowerCase() == 'malicious' || widget.id == 'V1023' || widget.id == 'V103' || widget.id == 'V106';
    final predictionLabel = isMalicious ? 'Prediction: Malicious Vehicle' : 'Prediction: Trusted Vehicle';
    final bannerColor = isMalicious ? AppTheme.error : AppTheme.safe;

    // SHAP Features from Mockup 6
    final shapFeatures = [
      {'name': 'Speed Anomaly', 'value': 0.42},
      {'name': 'Fake GPS Position', 'value': 0.31},
      {'name': 'High Message Frequency', 'value': 0.21},
      {'name': 'Acceleration Deviation', 'value': 0.12},
      {'name': 'Direction Inconsistency', 'value': 0.08},
    ];

    return Scaffold(
      backgroundColor: AppTheme.secondarySurface,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AI Explanation',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'AI Diagnostic certificate exported for Vehicle ${widget.id}',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Prediction Status Banner (Matching Mockup 6)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: bannerColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: bannerColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  predictionLabel,
                  style: GoogleFonts.outfit(
                    color: AppTheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Vehicle ID & Timestamp Meta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle ID: ${widget.id}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Time: 10:24 AM',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Reasons (SHAP) Card with Horizontal Bars (Matching Mockup 6)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
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
                    'Reasons (SHAP)',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...shapFeatures.map((feat) {
                    final name = feat['name'] as String;
                    final val = feat['value'] as double;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              name,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: val / 0.5,
                                backgroundColor: AppTheme.secondarySurface,
                                color: AppTheme.primary,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '+${val.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 LIME Explanation (Top Features) Donut Chart (Matching Mockup 6)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
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
                    'LIME Explanation (Top Features)',
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
                              PieChartSectionData(color: const Color(0xFF10B981), value: 42, radius: 20, showTitle: false),
                              PieChartSectionData(color: const Color(0xFF3B82F6), value: 31, radius: 20, showTitle: false),
                              PieChartSectionData(color: const Color(0xFFF59E0B), value: 21, radius: 20, showTitle: false),
                              PieChartSectionData(color: const Color(0xFF8B5CF6), value: 6, radius: 20, showTitle: false),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Donut Legend with Percentages
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLimeLegendRow('Speed', '42%', const Color(0xFF10B981)),
                            const SizedBox(height: 6),
                            _buildLimeLegendRow('GPS Position', '31%', const Color(0xFF3B82F6)),
                            const SizedBox(height: 6),
                            _buildLimeLegendRow('Msg Frequency', '21%', const Color(0xFFF59E0B)),
                            const SizedBox(height: 6),
                            _buildLimeLegendRow('Others', '6%', const Color(0xFF8B5CF6)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Full Action Button: "View Full Explanation" (Matching Mockup 6)
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
                onPressed: () {
                  setState(() => _showDeepDetails = !_showDeepDetails);
                },
                child: Text(
                  _showDeepDetails ? 'Hide Deep Telemetry' : 'View Full Explanation',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // 🔹 Preserved Deep Diagnostic Telemetry & Model Specifications
            if (_showDeepDetails) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Model Diagnostic Specifications',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMetaRow('Classifier Engine', 'XGBoost Telemetry Classifier v2.4'),
                    _buildMetaRow('VeReMi Attack Signature', 'Type 16 (Sybil Speed & Position Delta)'),
                    _buildMetaRow('Model Confidence Score', '99.4% Statistical Significance'),
                    _buildMetaRow('Bayesian Penalty Applied', '-52.0 reputation delta'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Root Cause: High packet frequency (85 pkts/sec) combined with abnormal velocity delta (+38 km/h variance from neighborhood average) caused high anomaly score.',
                        style: GoogleFonts.outfit(color: AppTheme.error, fontSize: 11.5, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLimeLegendRow(String title, String percent, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          percent,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 11.5, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
