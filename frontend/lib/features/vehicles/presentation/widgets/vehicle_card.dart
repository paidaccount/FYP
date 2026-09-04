import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/models/vehicle_model.dart';
import 'package:vanet_mobile/features/vehicles/presentation/widgets/trust_badge.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = vehicle.isEmergency
        ? AppTheme.error
        : (vehicle.trustScore >= 80
            ? AppTheme.safe
            : (vehicle.trustScore >= 40 ? AppTheme.warning : AppTheme.error));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: AppTheme.controlCardDecoration(
        borderColor: AppTheme.border,
        surfaceColor: AppTheme.surface,
        radius: 10,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Vehicle Icon Container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Icon(
                    vehicle.isEmergency ? Icons.local_hospital_outlined : Icons.directions_car_outlined,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Vehicle Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            vehicle.id,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (vehicle.isEmergency) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                'PRIORITY',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.error,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.speed_rounded, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            '${vehicle.speed} km/h',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.navigation_outlined, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            '${vehicle.direction}°',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trust Status & Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TrustBadge(status: vehicle.trustStatus),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.trustScore.toStringAsFixed(1)}% Trust',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
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
  }
}
