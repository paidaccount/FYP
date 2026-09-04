import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/features/authentication/presentation/auth_provider.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'SYSTEM CONFIGURATION',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Operator Profile Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: AppTheme.controlCardDecoration(
                borderColor: AppTheme.border,
                surfaceColor: AppTheme.surface,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(Icons.badge_outlined, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VANET Security Operator',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authState.email ?? 'operator@vanet-noc.transport.gov',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Operational Preferences Card
            Container(
              decoration: AppTheme.controlCardDecoration(
                borderColor: AppTheme.border,
                surfaceColor: AppTheme.surface,
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Critical Anomaly Push Alerts',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      'Immediate alerts for Sybil, DoS, and GPS falsification',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    activeThumbColor: AppTheme.primary,
                    value: true,
                    onChanged: (val) {},
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                  SwitchListTile(
                    title: Text(
                      'Emergency Siren Preemption Broadcast',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      'Relay priority corridor clearings to adjacent RSU nodes',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    activeThumbColor: AppTheme.primary,
                    value: true,
                    onChanged: (val) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Infrastructure Sync Status Card
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
                    'BACKEND INFRASTRUCTURE SYNC STATUS',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Divider(height: 18, color: AppTheme.border),
                  _buildSyncRow('API Ingestion Server (FastAPI)', 'CONNECTED • 200 OK', AppTheme.safe),
                  _buildSyncRow('WebSocket Telemetry Broadcaster', 'STREAMING', AppTheme.safe),
                  _buildSyncRow('VeReMi Machine Learning Pipeline', 'XGBoost v1.4 Loaded', AppTheme.primary),
                  _buildSyncRow('Explainable AI Subsystem', 'SHAP & LIME Active', AppTheme.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Action Button
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error, width: 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 17),
                label: Text(
                  'LOGOUT OPERATOR SESSION',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncRow(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11.5)),
          Text(
            status,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
