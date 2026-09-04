import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class TrustBadge extends StatelessWidget {
  final String status;

  const TrustBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;

    switch (status.toLowerCase()) {
      case 'trusted':
      case 'normal':
      case 'safe':
        badgeColor = AppTheme.safe;
        badgeIcon = Icons.check_circle_outline_rounded;
        break;
      case 'suspicious':
        badgeColor = AppTheme.warning;
        badgeIcon = Icons.warning_amber_rounded;
        break;
      case 'untrusted':
      case 'malicious':
      case 'critical':
        badgeColor = AppTheme.error;
        badgeIcon = Icons.gpp_bad_outlined;
        break;
      default:
        badgeColor = AppTheme.textSecondary;
        badgeIcon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: badgeColor, size: 11),
          const SizedBox(width: 3.5),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.outfit(
              color: badgeColor,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
