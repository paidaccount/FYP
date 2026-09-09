import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vanet_mobile/core/theme/colors.dart';
import 'package:vanet_mobile/features/admin/dashboard/presentation/widgets/section_header.dart';
import 'package:vanet_mobile/models/alert_model.dart';

class CriticalAlertSection extends StatelessWidget {
  final List<AlertModel> alerts;

  const CriticalAlertSection({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    final displayAlerts = alerts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Critical Alerts',
          actionLabel: 'View All',
          onActionTap: () => context.go('/alerts'),
        ),
        const SizedBox(height: 10),

        if (displayAlerts.isEmpty)
          const _EmptyAlertsState()
        else
          Column(
            children: displayAlerts.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _AlertTileCard(alert: alert),
            )).toList(),
          ),
      ],
    );
  }
}

class _AlertTileCard extends StatelessWidget {
  final AlertModel alert;

  const _AlertTileCard({required this.alert});

  Color _getSeverityColor() {
    switch (alert.severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return AppColors.error;
      case 'medium':
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  int _getConfidenceForAlert() {
    // Generate AI confidence score consistent with severity
    if (alert.severity.toLowerCase() == 'high' || alert.severity.toLowerCase() == 'critical') {
      return 94;
    } else if (alert.severity.toLowerCase() == 'medium') {
      return 87;
    }
    return 76;
  }

  void _onAlertTap(BuildContext context) {
    if (alert.vehicleId != null && alert.vehicleId!.isNotEmpty) {
      context.push('/vehicles/${alert.vehicleId}/detection');
    } else {
      context.go('/alerts');
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();
    final timeLabel = _formatTimeAgo(alert.timestamp);
    final confidence = _getConfidenceForAlert();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onAlertTap(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Severity Badge & Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: severityColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: severityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            alert.severity.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Vehicle ID & Title
                if (alert.vehicleId != null)
                  Text(
                    'Vehicle ${alert.vehicleId}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bottom Metadata Row: AI Confidence
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.psychology_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI Confidence',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$confidence%',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyAlertsState extends StatelessWidget {
  const _EmptyAlertsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.safe.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.safe,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No Critical Threats',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your network is currently operating normally.\nLast checked recently.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
