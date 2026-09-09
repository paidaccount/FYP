import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_provider.dart';

class NearbyVehiclesScreen extends ConsumerWidget {
  const NearbyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby V2V Radar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Radar Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.safe.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.safe.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: Icon(Icons.radar_rounded, color: AppTheme.safe, size: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'V2V Omni-Range Radar',
                        style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scanning 300m radius • 4 active BSM nodes detected',
                        style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Surrounding Transmitters',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),

          ...state.nearbyVehicles.map((vehicle) {
            final isUntrusted = vehicle.trustStatus == 'Untrusted';
            final isEmergency = vehicle.isEmergency;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUntrusted
                      ? AppTheme.error.withValues(alpha: 0.4)
                      : isEmergency
                          ? AppTheme.primary.withValues(alpha: 0.4)
                          : AppTheme.border,
                  width: (isUntrusted || isEmergency) ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isEmergency
                            ? AppTheme.error.withValues(alpha: 0.12)
                            : isUntrusted
                                ? AppTheme.error.withValues(alpha: 0.12)
                                : AppTheme.safe.withValues(alpha: 0.12),
                        child: Icon(
                          isEmergency
                              ? Icons.emergency_rounded
                              : isUntrusted
                                  ? Icons.warning_amber_rounded
                                  : Icons.directions_car_rounded,
                          color: isEmergency
                              ? AppTheme.error
                              : isUntrusted
                                  ? AppTheme.error
                                  : AppTheme.safe,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  vehicle.id,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                _tagChip(
                                  isEmergency
                                      ? 'EMERGENCY'
                                      : isUntrusted
                                          ? 'MALICIOUS / LOW TRUST'
                                          : 'VERIFIED SAFE',
                                  isEmergency
                                      ? AppTheme.error
                                      : isUntrusted
                                          ? AppTheme.error
                                          : AppTheme.safe,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Direction: ${vehicle.direction} • Speed: ${vehicle.speed.toInt()} km/h',
                              style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trust Rating: ${(vehicle.trustScore * 100).toInt()}%',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: isUntrusted ? AppTheme.error : AppTheme.safe,
                        ),
                      ),
                      if (isUntrusted)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: const Icon(Icons.psychology_rounded, size: 14),
                          label: Text('View AI Reason', style: GoogleFonts.outfit(fontSize: 11)),
                          onPressed: () => context.push('/driver/xai/${vehicle.id}'),
                        )
                      else if (isEmergency)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Preemption Requested',
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tagChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
