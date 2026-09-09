import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class DriverXAIScreen extends StatelessWidget {
  final String vehicleId;

  const DriverXAIScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Safety Explanation', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target Vehicle Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Untrusted Vehicle #$vehicleId',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Flagged by XGBoost Anomaly Classifier + SHAP Explainability',
                          style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Plain Language Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Why did AI flag this vehicle?',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The OBU machine learning model detected inconsistent kinematic messages transmitted by vehicle $vehicleId. The broadcasted speed violates basic laws of physics relative to physical radar tracking.',
                    style: GoogleFonts.outfit(fontSize: 13, height: 1.4, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Top Contributing Factors (SHAP simplified)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key AI Anomaly Factors', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _factorRow(
                    factor: 'Speed Discrepancy (Δv)',
                    value: '+66.4 km/h jump in 0.1s',
                    impact: '+42% Malicious Weight',
                    color: AppTheme.error,
                  ),
                  const Divider(height: 16),
                  _factorRow(
                    factor: 'GPS Kalman Drift',
                    value: 'Location jumped 140m across building',
                    impact: '+31% Malicious Weight',
                    color: AppTheme.error,
                  ),
                  const Divider(height: 16),
                  _factorRow(
                    factor: 'Acceleration Impossibility',
                    value: '18.4 m/s² (Exceeds sedan physical limits)',
                    impact: '+19% Malicious Weight',
                    color: AppTheme.warning,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recommended Action for Driver
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.safe.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.safe.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: AppTheme.safe, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Driver Safety Advisory',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.safe),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Maintain at least 25 meters following distance.\n2. Do not rely on forward collision alerts broadcasted by this node.\n3. Safe detour recommended to avoid potential collision spoofing.',
                    style: GoogleFonts.outfit(fontSize: 12.5, height: 1.4, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _factorRow({
    required String factor,
    required String value,
    required String impact,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(factor, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(impact, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
