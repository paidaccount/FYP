import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  IconData _resolveIcon() {
    if (icon != null) return icon!;
    final lower = label.toLowerCase();
    if (lower.contains('trusted') || lower.contains('normal') || lower.contains('safe')) {
      return Icons.check_circle_outline_rounded;
    } else if (lower.contains('suspicious') || lower.contains('warning')) {
      return Icons.warning_amber_rounded;
    } else if (lower.contains('untrusted') || lower.contains('malicious') || lower.contains('critical')) {
      return Icons.gpp_bad_outlined;
    } else if (lower.contains('connected') || lower.contains('online')) {
      return Icons.sensors_rounded;
    } else if (lower.contains('emergency') || lower.contains('priority')) {
      return Icons.local_hospital_outlined;
    }
    return Icons.info_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final displayIcon = _resolveIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(displayIcon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
