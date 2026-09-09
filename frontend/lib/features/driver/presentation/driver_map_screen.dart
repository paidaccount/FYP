import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_provider.dart';

class DriverMapScreen extends ConsumerWidget {
  const DriverMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Simulated Interactive Map Canvas
          Container(
            color: const Color(0xFF1E293B),
            child: CustomPaint(
              painter: _MapCanvasPainter(),
              child: const SizedBox.expand(),
            ),
          ),

          // Top Floating Navigation Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation_rounded, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('In 200m Turn Right onto Faisal Avenue', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text('Corridor Green-Wave Active • Speed limit: 60 km/h', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.safe.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text('SAFE ZONE', style: GoogleFonts.outfit(color: AppTheme.safe, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Floating HUD Cards
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _hudItem('LIVE SPEED', '${state.currentSpeed.toInt()} km/h', Colors.white),
                  Container(height: 36, width: 1, color: Colors.white24),
                  _hudItem('TRUST SCORE', '${(state.trustScore * 100).toInt()}%', const Color(0xFF38BDF8)),
                  Container(height: 36, width: 1, color: Colors.white24),
                  _hudItem('ACTIVE NODES', '${state.nearbyVehicles.length} V2V', const Color(0xFF4ADE80)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.outfit(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corridorPaint = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.45)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerLinePaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw Roads
    final path = Path();
    path.moveTo(size.width * 0.2, size.height);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.5, size.width * 0.5, size.height * 0.4);
    path.lineTo(size.width * 0.85, size.height * 0.1);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, corridorPaint);
    canvas.drawPath(path, centerLinePaint);

    // Draw My Vehicle Dot
    final myVehiclePaint = Paint()..color = const Color(0xFF38BDF8);
    final myVehicleCenter = Offset(size.width * 0.42, size.height * 0.46);
    canvas.drawCircle(myVehicleCenter, 10, myVehiclePaint);

    final pulsePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(myVehicleCenter, 22, pulsePaint);

    // Draw Nearby Rogue Node Dot
    final roguePaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.26), 8, roguePaint);

    // Draw RSU Tower Dot
    final rsuPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.35), 7, rsuPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
