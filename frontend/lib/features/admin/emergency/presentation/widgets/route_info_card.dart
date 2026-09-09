import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/models/route_model.dart';

class RouteInfoCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onStart;
  final VoidCallback onViewAlternative;

  const RouteInfoCard({
    super.key,
    required this.route,
    required this.onStart,
    required this.onViewAlternative,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16.0),
      decoration: AppTheme.controlCardDecoration(
        borderColor: AppTheme.border,
        surfaceColor: AppTheme.surface,
        radius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A* RECOMMENDED DETOUR CORRIDOR',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.safe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.safe.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'OPTIMAL PATH',
                  style: GoogleFonts.outfit(
                    color: AppTheme.safe,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('DISTANCE', route.distance),
                _buildMetric('EST. TIME', route.eta),
                _buildMetric('CONGESTION', route.traffic),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onViewAlternative,
                  child: Text(
                    'COMPARE DIJKSTRA',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onStart,
                  child: Text(
                    'BROADCAST PREEMPTION',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppTheme.textSecondary,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
