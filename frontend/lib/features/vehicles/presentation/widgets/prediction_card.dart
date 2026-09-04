import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/models/explanation_model.dart';
import 'package:vanet_mobile/widgets/status_badge.dart';

class PredictionCard extends StatelessWidget {
  final ExplanationModel explanation;
  final VoidCallback onTap;

  const PredictionCard({
    super.key,
    required this.explanation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMalicious = explanation.prediction.toLowerCase() == 'malicious';
    final severityColor = isMalicious ? AppTheme.error : AppTheme.safe;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16.0),
      decoration: AppTheme.controlCardDecoration(
        borderColor: AppTheme.border,
        surfaceColor: AppTheme.surface,
        radius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MODEL SECURITY CLASSIFICATION',
                style: GoogleFonts.outfit(
                  color: AppTheme.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              StatusBadge(
                label: explanation.prediction,
                color: severityColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                explanation.modelName,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${explanation.confidence.toStringAsFixed(1)}% Conf.',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: AppTheme.border),
          Text(
            'Attack Vector Signature:',
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            explanation.attackType,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isMalicious ? AppTheme.error : AppTheme.safe,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation.humanReason,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onTap,
              icon: const Icon(Icons.analytics_outlined, size: 16),
              label: Text(
                'INSPECT XAI (SHAP & LIME)',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
