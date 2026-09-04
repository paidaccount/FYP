import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final VoidCallback? onTap;
  final bool isSolid;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.onTap,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBgColor = isSolid ? AppTheme.primary : AppTheme.surface;
    final primaryTextColor = isSolid ? Colors.white : AppTheme.textPrimary;
    final secondaryTextColor = isSolid ? Colors.white.withValues(alpha: 0.85) : AppTheme.textSecondary;
    final iconColor = isSolid ? Colors.white : color;
    final iconBgColor = isSolid ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.1);
    final borderColor = isSolid ? const Color(0xFFD34F1D) : AppTheme.border;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isSolid
            ? const [
                BoxShadow(
                  color: Color.fromRGBO(230, 95, 43, 0.2),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.04),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSolid ? Colors.white.withValues(alpha: 0.3) : color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    if (trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSolid ? Colors.white.withValues(alpha: 0.22) : color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: isSolid ? Border.all(color: Colors.white.withValues(alpha: 0.35)) : null,
                        ),
                        child: Text(
                          trend!,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: isSolid ? Colors.white : color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        color: primaryTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: secondaryTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
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
