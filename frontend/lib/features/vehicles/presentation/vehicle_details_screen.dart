import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/dashboard/presentation/dashboard_provider.dart';
import 'package:vanet_mobile/features/trust/presentation/widgets/trust_chart.dart';
import 'package:vanet_mobile/features/vehicles/presentation/widgets/trust_badge.dart';

class VehicleDetailsScreen extends ConsumerWidget {
  final String id;

  const VehicleDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    final vehicle = state.vehicles.firstWhere(
      (v) => v.id == id,
      orElse: () => state.vehicles.first,
    );

    final trustInfo = state.trustRankings.firstWhere(
      (t) => t.vehicleId == id,
      orElse: () => state.trustRankings.first,
    );

    final statusColor = vehicle.isEmergency
        ? AppTheme.error
        : (vehicle.trustScore >= 80
            ? AppTheme.safe
            : (vehicle.trustScore >= 40 ? AppTheme.warning : AppTheme.error));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Vehicle Details',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Telemetry & Kinematics Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: AppTheme.controlCardDecoration(
                borderColor: AppTheme.border,
                surfaceColor: AppTheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VEHICLE OVERVIEW & KINEMATICS',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TrustBadge(status: vehicle.trustStatus),
                    ],
                  ),
                  const Divider(height: 20, color: AppTheme.border),
                  _buildRow('Vehicle Identifier', vehicle.id, isBold: true),
                  _buildRow('Reported Speed', '${vehicle.speed} km/h'),
                  _buildRow('Acceleration', '${vehicle.acceleration} m/s²'),
                  _buildRow('Heading Vector', '${vehicle.direction}°'),
                  _buildRow('GPS Coordinates', '${vehicle.latitude.toStringAsFixed(4)}, ${vehicle.longitude.toStringAsFixed(4)}'),
                  _buildRow('Beacon Frequency', '10 Hz (IEEE 802.11p BSM)'),
                  _buildRow('Connection Standing', 'Actively Broadcasting', color: AppTheme.safe),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 🔹 Dynamic Trust Evaluation Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: AppTheme.controlCardDecoration(
                borderColor: AppTheme.border,
                surfaceColor: AppTheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DYNAMIC TRUST EVALUATION',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${vehicle.trustScore.toStringAsFixed(1)} / 100',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (vehicle.trustScore / 100).clamp(0.0, 1.0),
                      backgroundColor: AppTheme.secondarySurface,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Assessment Justification:',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trustInfo.reason,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 🔹 Trust History Convergence Plot
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
                    'TEMPORAL TRUST HISTORY CURVE',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bayesian penalty & recovery trend over time intervals',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TrustChart(history: trustInfo.trustHistory),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🔹 View Explainable AI Button
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: Text(
                  'INSPECT AI EXPLANATION (SHAP & LIME)',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: 12,
                  ),
                ),
                onPressed: () => context.push('/vehicles/$id/explanation'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 12.5,
              color: color ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
