import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/models/alert_model.dart';
import 'package:vanet_mobile/widgets/status_badge.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    switch (alert.severity.toLowerCase()) {
      case 'high':
      case 'critical':
        severityColor = AppTheme.error;
        break;
      case 'medium':
      case 'warning':
        severityColor = AppTheme.warning;
        break;
      default:
        severityColor = AppTheme.primary;
    }

    IconData alertIcon;
    switch (alert.category.toLowerCase()) {
      case 'security':
        alertIcon = Icons.shield_outlined;
        break;
      case 'emergency':
        alertIcon = Icons.local_hospital_outlined;
        break;
      case 'traffic':
        alertIcon = Icons.traffic_rounded;
        break;
      default:
        alertIcon = Icons.info_outline_rounded;
    }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: severityColor.withValues(alpha: 0.25)),
                  ),
                  child: Icon(alertIcon, color: severityColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          StatusBadge(label: alert.severity, color: severityColor),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        alert.description,
                        style: GoogleFonts.outfit(
                          color: AppTheme.textSecondary,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'DOMAIN: ${alert.category.toUpperCase()}',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${DateTime.now().difference(alert.timestamp).inMinutes}m ago',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 9.5,
                            ),
                          ),
                          if (alert.vehicleId != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•  Target: ${alert.vehicleId}',
                              style: GoogleFonts.outfit(
                                color: AppTheme.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
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
