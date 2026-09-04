import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vanet_mobile/core/theme/colors.dart';
import 'package:vanet_mobile/features/dashboard/presentation/widgets/section_header.dart';
import 'package:vanet_mobile/models/vehicle_model.dart';

class LiveNetworkPreview extends StatelessWidget {
  final List<VehicleModel> vehicles;

  const LiveNetworkPreview({
    super.key,
    required this.vehicles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Live Network',
          actionLabel: 'View Map',
          onActionTap: () => context.push('/emergency/route'),
        ),
        const SizedBox(height: 10),

        // Compact Map Preview Card
        Container(
          height: 190,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/emergency/route'),
                child: Stack(
                  children: [
                    // Vector Road Grid Paint
                    CustomPaint(
                      size: const Size(double.infinity, 190),
                      painter: _MapRoadGridPainter(),
                    ),

                    // Vehicle Nodes on Map
                    _buildNodeMarker(top: 45, left: 60, color: AppColors.safe, label: 'V-101', icon: Icons.directions_car_rounded),
                    _buildNodeMarker(top: 35, left: 200, color: AppColors.warning, label: 'V-203', icon: Icons.warning_rounded),
                    _buildNodeMarker(top: 110, left: 140, color: AppColors.error, label: 'V-305', icon: Icons.gpp_bad_rounded),
                    _buildNodeMarker(top: 95, left: 260, color: const Color(0xFF2563EB), label: 'V-404', icon: Icons.local_hospital_rounded),

                    // Floating Tooltip
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.touch_app_outlined, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Tap map to expand',
                              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Status Legend Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendDot('Trusted', AppColors.safe),
            _buildLegendDot('Suspicious', AppColors.warning),
            _buildLegendDot('Malicious', AppColors.error),
            _buildLegendDot('Emergency', const Color(0xFF2563EB)),
          ],
        ),
      ],
    );
  }

  Widget _buildNodeMarker({
    required double top,
    required double left,
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 12, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border, width: 0.6),
            ),
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MapRoadGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeRoutePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPath1 = Path()
      ..moveTo(20, 45)
      ..lineTo(size.width * 0.45, 45)
      ..lineTo(size.width * 0.65, 115)
      ..lineTo(size.width - 20, 115);

    final gridPath2 = Path()
      ..moveTo(size.width * 0.45, 45)
      ..lineTo(size.width * 0.45, size.height - 25)
      ..lineTo(size.width * 0.85, size.height - 25);

    canvas.drawPath(gridPath1, roadPaint);
    canvas.drawPath(gridPath2, roadPaint);

    final activePath = Path()
      ..moveTo(60, 45)
      ..lineTo(size.width * 0.45, 45)
      ..lineTo(size.width * 0.65, 115)
      ..lineTo(size.width * 0.75, 115);

    canvas.drawPath(activePath, activeRoutePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
