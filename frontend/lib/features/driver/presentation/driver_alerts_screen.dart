import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_provider.dart';

class DriverAlertsScreen extends ConsumerWidget {
  const DriverAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider);
    final notifier = ref.read(driverProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Suspicious Vehicle & Safety Alerts', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: state.activeAlerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppTheme.safe),
                  const SizedBox(height: 12),
                  Text('All Clear Around Your Vehicle', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('No suspicious broadcasts or hazards in range.', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.activeAlerts.length,
              itemBuilder: (context, index) {
                final alert = state.activeAlerts[index];
                final isCritical = alert.severity.toLowerCase() == 'critical' || alert.severity.toLowerCase() == 'high';
                final isMedium = alert.severity.toLowerCase() == 'medium';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCritical
                          ? AppTheme.error
                          : isMedium
                              ? AppTheme.primary
                              : AppTheme.border,
                      width: isCritical ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: (isCritical ? AppTheme.error : AppTheme.primary).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  isCritical ? Icons.warning_rounded : Icons.info_outline_rounded,
                                  color: isCritical ? AppTheme.error : AppTheme.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                alert.title,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCritical ? AppTheme.error : AppTheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              alert.severity.toUpperCase(),
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        alert.description,
                        style: GoogleFonts.outfit(fontSize: 12.5, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (alert.vehicleId != null && alert.vehicleId!.startsWith('V'))
                            TextButton.icon(
                              icon: const Icon(Icons.psychology_rounded, size: 16),
                              label: Text('Explain AI Detection', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5)),
                              onPressed: () => context.push('/driver/xai/${alert.vehicleId}'),
                            ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            onPressed: () => notifier.dismissAlert(alert.id),
                            child: Text('Acknowledge', style: GoogleFonts.outfit(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
