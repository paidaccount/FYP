import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_provider.dart';

class MyVehicleScreen extends ConsumerWidget {
  const MyVehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Vehicle & OBU Trust', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle Hero Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.directions_car_rounded, size: 40, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.vehicleId,
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${state.licensePlate} • ${state.vehicleType}',
                    style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statusChip(label: 'OBU ACTIVE', color: AppTheme.safe),
                      const SizedBox(width: 8),
                      _statusChip(label: 'TRUSTED NODE', color: const Color(0xFF2563EB)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Trust Score Breakdown
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
                  Text('VANET Trust Score Analysis', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _trustMetricRow('Direct Evaluation (V2V Consensus)', '96%', 0.96, AppTheme.safe),
                  const SizedBox(height: 10),
                  _trustMetricRow('RSU Infrastructure Verification', '92%', 0.92, AppTheme.safe),
                  const SizedBox(height: 10),
                  _trustMetricRow('Kinematic Telemetry Consistency', '95%', 0.95, AppTheme.safe),
                  const SizedBox(height: 10),
                  _trustMetricRow('Historical Behavior Credibility', '93%', 0.93, AppTheme.safe),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // OBU Hardware & Communication Specs
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
                  Text('On-Board Unit (OBU) Diagnostics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _infoRow('Protocol', 'IEEE 802.11p / DSRC + C-V2X'),
                  _infoRow('Broadcast Interval', '100 ms (10 Hz BSM)'),
                  _infoRow('Crypto Engine', 'ECDSA NIST P-256 Signatures'),
                  _infoRow('Active Channels', 'CCH (178), SCH1 (172)'),
                  _infoRow('Antenna Sensitivity', '-94 dBm (Excellent)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _trustMetricRow(String title, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textPrimary)),
            Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.border,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
