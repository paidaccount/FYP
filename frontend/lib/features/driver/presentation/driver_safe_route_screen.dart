import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class DriverSafeRouteScreen extends StatelessWidget {
  const DriverSafeRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Safe Detour Routing (A*)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Destination & Route Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Current Origin: Blue Area, Islamabad',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 9),
                    child: SizedBox(
                      height: 16,
                      child: VerticalDivider(color: AppTheme.border, thickness: 1.5),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppTheme.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Destination: PIMS Hospital / G-8 Medical Hub',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Route Comparison (Primary Safe Route vs Compromised Direct Route)
            Text('Recommended Safe Trajectory', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            _routeOptionCard(
              title: 'Route A — AI Verified Safe Corridor (Recommended)',
              via: 'Via 7th Avenue & Faisal Avenue (Avoids Sector F-8 Sybil Cluster)',
              eta: '11 mins (6.4 km)',
              trustRating: '99% Verified Safe Nodes',
              trustColor: AppTheme.safe,
              isRecommended: true,
              algorithm: 'Optimized via Dijkstra + A* Cost Function: Cost = Distance + 2.5*(1 - NodeTrust)',
            ),

            const SizedBox(height: 12),

            _routeOptionCard(
              title: 'Route B — Direct Route (Security Alert)',
              via: 'Via Margalla Road',
              eta: '14 mins (5.1 km)',
              trustRating: '52% High Risk (3 Spoofed Telemetry Nodes)',
              trustColor: AppTheme.error,
              isRecommended: false,
              algorithm: 'Contains 2 vehicles with active False Speed Injection warnings.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeOptionCard({
    required String title,
    required String via,
    required String eta,
    required String trustRating,
    required Color trustColor,
    required bool isRecommended,
    required String algorithm,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended ? AppTheme.surface : AppTheme.secondarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRecommended ? AppTheme.safe : AppTheme.border,
          width: isRecommended ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5)),
              ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.safe, borderRadius: BorderRadius.circular(4)),
                  child: Text('OPTIMAL', style: GoogleFonts.outfit(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(via, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(eta, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(trustRating, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: trustColor)),
            ],
          ),
          const Divider(height: 16),
          Text(algorithm, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
