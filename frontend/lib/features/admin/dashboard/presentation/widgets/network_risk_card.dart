import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/colors.dart';
import 'package:vanet_mobile/features/admin/dashboard/presentation/widgets/network_risk_details_sheet.dart';

class NetworkRiskCard extends StatelessWidget {
  final int riskScore; // 0 to 100
  final String riskLevel; // e.g. 'Moderate Risk', 'Low Risk', 'High Risk'
  final int suspiciousCount;
  final int activeAttacksCount;
  final int emergencyCount;
  final int anomalyCount;

  const NetworkRiskCard({
    super.key,
    required this.riskScore,
    required this.riskLevel,
    this.suspiciousCount = 0,
    this.activeAttacksCount = 0,
    this.emergencyCount = 0,
    this.anomalyCount = 0,
  });

  Color _getRiskColor() {
    if (riskScore >= 75) return AppColors.error;
    if (riskScore >= 40) return AppColors.warning;
    return AppColors.safe;
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NetworkRiskDetailsSheet(
        riskScore: riskScore,
        riskLevel: riskLevel,
        suspiciousCount: suspiciousCount,
        activeAttacksCount: activeAttacksCount,
        emergencyCount: emergencyCount,
        anomalyCount: anomalyCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetails(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            child: Row(
              children: [
                // Left Side Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'NETWORK RISK',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$riskScore',
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            ' / 100',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: riskColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              riskLevel,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Side Arc Gauge
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                    painter: _RiskGaugePainter(
                      score: riskScore,
                      color: riskColor,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 24,
                            color: riskColor,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap details',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RiskGaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _RiskGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Draw background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Draw active progress
    final currentSweep = (score / 100.0) * sweepAngle;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RiskGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
