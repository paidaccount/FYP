import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/admin/dashboard/presentation/dashboard_provider.dart';
import 'package:vanet_mobile/features/admin/vehicles/presentation/widgets/trust_badge.dart';
import 'package:vanet_mobile/features/admin/trust/presentation/widgets/trust_chart.dart';
import 'package:vanet_mobile/widgets/stat_card.dart';

class TrustManagementScreen extends ConsumerWidget {
  const TrustManagementScreen({super.key});

  void _showTrustDetails(BuildContext context, String vehicleId, WidgetRef ref) {
    final state = ref.read(dashboardProvider);
    final trust = state.trustRankings.firstWhere(
      (t) => t.vehicleId == vehicleId,
      orElse: () => state.trustRankings.first,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRUST AUDIT: $vehicleId',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondarySurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailCol('CURRENT TRUST', '${trust.currentTrust}%', color: AppTheme.safe),
                    _buildDetailCol('PREVIOUS TRUST', '${trust.previousTrust}%'),
                    _buildDetailCol(
                      'DELTA',
                      '${trust.trustChange >= 0 ? '+' : ''}${trust.trustChange}%',
                      color: trust.trustChange >= 0 ? AppTheme.safe : AppTheme.error,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                trust.reason,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'TEMPORAL CONVERGENCE',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TrustChart(history: trust.trustHistory),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDetailCol(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppTheme.textSecondary,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    final trustedCount = state.vehicles.isEmpty ? 20 : state.vehicles.where((v) => v.trustStatus.toLowerCase() == 'trusted').length;
    final suspiciousCount = state.vehicles.isEmpty ? 3 : state.vehicles.where((v) => v.trustStatus.toLowerCase() == 'suspicious').length;
    final untrustedCount = state.vehicles.isEmpty ? 1 : state.vehicles.where((v) => v.trustStatus.toLowerCase() == 'untrusted').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trust Management',
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
            // 🔹 3 Trust Category Summary Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Trusted',
                    value: '$trustedCount',
                    icon: Icons.verified_user_outlined,
                    color: AppTheme.safe,
                    trend: '80-100 pts',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    title: 'Suspicious',
                    value: '$suspiciousCount',
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.warning,
                    trend: '40-79 pts',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    title: 'Untrusted',
                    value: '$untrustedCount',
                    icon: Icons.gpp_bad_outlined,
                    color: AppTheme.error,
                    trend: '<40 pts',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'DYNAMIC VEHICLE TRUST LEADERBOARD',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
                letterSpacing: 0.8,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Trust Rankings List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.trustRankings.length,
              itemBuilder: (context, index) {
                final trust = state.trustRankings[index];
                final score = trust.currentTrust;
                final statusColor = score >= 80
                    ? AppTheme.safe
                    : (score >= 40 ? AppTheme.warning : AppTheme.error);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: AppTheme.controlCardDecoration(
                    borderColor: AppTheme.border,
                    surfaceColor: AppTheme.surface,
                    radius: 10,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showTrustDetails(context, trust.vehicleId, ref),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                              ),
                              child: Center(
                                child: Text(
                                  '#${index + 1}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trust.vehicleId,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    trust.reason,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TrustBadge(
                                  status: score >= 80 ? 'Trusted' : (score >= 40 ? 'Suspicious' : 'Untrusted'),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$score%',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
