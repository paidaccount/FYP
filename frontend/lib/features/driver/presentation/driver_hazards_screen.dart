import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class DriverHazardsScreen extends StatelessWidget {
  const DriverHazardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accident & Road Hazards', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _hazardCard(
            title: 'Sudden Braking Warning',
            location: '150m Ahead • Sector F-7 / Blue Area',
            severity: 'CRITICAL',
            severityColor: AppTheme.error,
            icon: Icons.car_crash_rounded,
            description: 'Lead vehicle #V4091 triggered Emergency Electronic Brake Light (EEBL). Reduce speed immediately.',
            time: 'Just now',
          ),
          _hazardCard(
            title: 'Slippery Road Surface (RSU-04)',
            location: '400m Ahead • 9th Avenue Underpass',
            severity: 'WARNING',
            severityColor: const Color(0xFFD97706),
            icon: Icons.water_drop_rounded,
            description: 'Roadside Unit #04 optical sensors detected standing water & low tire traction. Recommended speed: < 40 km/h.',
            time: '4 mins ago',
          ),
          _hazardCard(
            title: 'Minor Multi-Vehicle Collision',
            location: '1.2 km Ahead • Kashmir Highway Exit 3',
            severity: 'ADVISORY',
            severityColor: const Color(0xFF2563EB),
            icon: Icons.minor_crash_rounded,
            description: '2 vehicles pulled over on right shoulder. Lane 1 & 2 clear. Traffic moving at 35 km/h.',
            time: '18 mins ago',
          ),
        ],
      ),
    );
  }

  Widget _hazardCard({
    required String title,
    required String location,
    required String severity,
    required Color severityColor,
    required IconData icon,
    required String description,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: severityColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(location, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  severity,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: GoogleFonts.outfit(fontSize: 12.5, color: AppTheme.textPrimary, height: 1.35)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reported: $time', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
              Text('Verified via V2X Consensus', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.safe)),
            ],
          ),
        ],
      ),
    );
  }
}
