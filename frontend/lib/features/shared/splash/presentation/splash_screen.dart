import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/shared/authentication/presentation/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        ref.read(authProvider.notifier).completeSplash();
        final authState = ref.read(authProvider);
        if (authState.isAuthenticated) {
          context.go(authState.isAdmin ? '/dashboard' : '/driver/dashboard');
        } else if (authState.hasSeenOnboarding) {
          context.go('/login');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 3),

                          // 🔹 Unique VANET Logo Emblem
                          const Center(
                            child: _VanetUniqueLogoWidget(),
                          ),

                          const SizedBox(height: 28),

                          // 🔹 App Title: "VANET Security Monitor"
                          Text(
                            'VANET',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              letterSpacing: 1.5,
                              height: 1.1,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Security Monitor',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 25,
                              height: 1.15,
                              color: AppTheme.primary,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 🔹 Subtitle: "AI-Powered Vehicle Network Security"
                          Text(
                            'AI-Powered Vehicle Network Security',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),

                          const Spacer(flex: 4),

                          // 🔹 Bottom Tagline: "Smart • Secure • Connected"
                          Text(
                            'Smart • Secure • Connected',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.6,
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Unique VANET Security Monitor Logo Badge Widget
class _VanetUniqueLogoWidget extends StatelessWidget {
  const _VanetUniqueLogoWidget();

  @override
  Widget build(BuildContext context) {
    const double size = 200;
    const Color outerDark = Color(0xFF161F30);
    const Color orangeAccent = AppTheme.primary;
    const Color nodeGlow = Color(0xFF64748B);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dark circle badge with soft subtle shadow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: outerDark,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: orangeAccent.withValues(alpha: 0.2),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          // Radiating VANET Network Mesh Nodes
          CustomPaint(
            size: const Size(size, size),
            painter: _RadiatingNetworkNodesPainter(
              nodeColor: nodeGlow,
              lineColor: nodeGlow.withValues(alpha: 0.6),
            ),
          ),

          // Central Security Shield Emblem with Vehicle Silhouette
          Container(
            width: 104,
            height: 114,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              border: Border.all(color: orangeAccent, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: orangeAccent.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner Shield Ring Accent
                Container(
                  width: 86,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    border: Border.all(
                      color: orangeAccent.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                ),

                // Center Vehicle Silhouette Icon
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 20,
                      color: orangeAccent,
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      Icons.directions_car_filled_rounded,
                      size: 42,
                      color: orangeAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter drawing radiating network lines & nodes around the central logo shield
class _RadiatingNetworkNodesPainter extends CustomPainter {
  final Color nodeColor;
  final Color lineColor;

  _RadiatingNetworkNodesPainter({
    required this.nodeColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.fill;

    // 8 Radial Node Points around the circle
    final List<Offset> outerNodes = [
      Offset(center.dx - 65, center.dy - 65),
      Offset(center.dx, center.dy - 82),
      Offset(center.dx + 65, center.dy - 65),
      Offset(center.dx + 82, center.dy),
      Offset(center.dx + 65, center.dy + 65),
      Offset(center.dx, center.dy + 82),
      Offset(center.dx - 65, center.dy + 65),
      Offset(center.dx - 82, center.dy),
    ];

    // Inner anchor points attached to shield perimeter
    final List<Offset> innerAnchors = [
      Offset(center.dx - 45, center.dy - 45),
      Offset(center.dx, center.dy - 55),
      Offset(center.dx + 45, center.dy - 45),
      Offset(center.dx + 52, center.dy),
      Offset(center.dx + 45, center.dy + 45),
      Offset(center.dx, center.dy + 55),
      Offset(center.dx - 45, center.dy + 45),
      Offset(center.dx - 52, center.dy),
    ];

    for (int i = 0; i < outerNodes.length; i++) {
      canvas.drawLine(innerAnchors[i], outerNodes[i], linePaint);
      canvas.drawCircle(outerNodes[i], 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


