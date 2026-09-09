import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/models/vehicle_model.dart';

class FakeEmergencyScreen extends StatelessWidget {
  final VehicleModel vehicle;

  const FakeEmergencyScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondarySurface,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Emergency Verification',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Threat Warning Header Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.35), width: 1.2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gpp_bad_outlined, color: AppTheme.error, size: 36),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'FAKE EMERGENCY BEACON INTERCEPTED',
                    style: GoogleFonts.outfit(
                      color: AppTheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Priority preemption request intercepted and flagged as an unverified Sybil / spoofed beacon',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 🔹 Assessment Details
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: AppTheme.controlCardDecoration(
                borderColor: AppTheme.border,
                surfaceColor: AppTheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTERCEPT ASSESSMENT DETAILS',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Divider(height: 18, color: AppTheme.border),
                  _buildRow('Target Vehicle ID', vehicle.id, isBold: true),
                  _buildRow('Claimed Emergency Type', 'Ambulance Preemption Request'),
                  _buildRow('PKI Certificate Validation', 'FAILED (Signature Invalid)', color: AppTheme.error),
                  _buildRow('Dynamic Trust Score', '${vehicle.trustScore.toStringAsFixed(1)}%', color: AppTheme.error, isBold: true),
                  _buildRow('Security Standing', vehicle.trustStatus.toUpperCase(), color: AppTheme.error, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 🔹 Classification Logs
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: AppTheme.controlCardDecoration(
                borderColor: AppTheme.border,
                surfaceColor: AppTheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ML CLASSIFIER DIAGNOSTIC LOGS',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Divider(height: 18, color: AppTheme.border),
                  _buildRow('Classifier Engine', 'XGBoost Threat Diagnostic Model'),
                  _buildRow('Attack Vector Type', vehicle.attackType),
                  _buildRow('Attack Incident Count', '1 Active Event Detected'),
                  const SizedBox(height: 10),
                  Text(
                    'Diagnostic Reasoning:',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vehicle ${vehicle.id} claimed emergency transit privilege but failed basic cryptographic PKI verification checks, indicating spoofed priority telemetry.',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/vehicles/${vehicle.id}'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: Text(
                      'View Node Telemetry',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/vehicles/${vehicle.id}/explanation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Inspect AI Explanation',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11.5)),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppTheme.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
