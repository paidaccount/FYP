import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/shared/authentication/presentation/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      title: 'Connect Every Vehicle',
      subtitle: 'Monitor connected vehicles and keep communication across the network secure and reliable.',
      type: OnboardingType.connectedVehicles,
    ),
    OnboardingData(
      title: 'Real-Time Threat Detection',
      subtitle: 'Detect unusual kinematics, Sybil attacks, and message tampering using explainable AI.',
      type: OnboardingType.aiDetection,
    ),
    OnboardingData(
      title: 'Secure & Trusted Network',
      subtitle: 'Dynamic trust scores ensure only verified vehicular nodes exchange safety-critical messages.',
      type: OnboardingType.secureTrust,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      ref.read(authProvider.notifier).completeOnboarding();
      context.go('/login');
    }
  }

  void _onSkip() {
    ref.read(authProvider.notifier).completeOnboarding();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeAccent = Color(0xFFE45D3F);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Onboarding Carousel (Scrollable & Responsive)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🔹 Upper-Middle Vector Illustration
                            _buildIllustrationWidget(data.type),

                            const SizedBox(height: 24),

                            // 🔹 Heading: Bold Dark Navy Typography
                            Text(
                              data.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 25,
                                height: 1.2,
                                color: AppTheme.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // 🔹 Description: Clean Light Gray Secondary Text
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Text(
                                data.subtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13.5,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 Bottom Controls: Page Indicator + Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicator: ○ ○ ●
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? orangeAccent
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Primary Rounded Orange Button: "Next" / "Get Started"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadowColor: orangeAccent.withValues(alpha: 0.3),
                      ),
                      onPressed: _onNext,
                      child: Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Small Text Button: "Skip"
                  SizedBox(
                    height: 36,
                    child: !isLastPage
                        ? TextButton(
                            onPressed: _onSkip,
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustrationWidget(OnboardingType type) {
    switch (type) {
      case OnboardingType.connectedVehicles:
        return const _ConnectedVehiclesRoadIllustration();
      case OnboardingType.aiDetection:
        return const _AiDetectionIllustration();
      case OnboardingType.secureTrust:
        return const _SecureTrustIllustration();
    }
  }
}

enum OnboardingType {
  connectedVehicles,
  aiDetection,
  secureTrust,
}

class OnboardingData {
  final String title;
  final String subtitle;
  final OnboardingType type;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

/// 🚗 Main Vector Illustration: Connected Cars on Road with Wireless Signals
class _ConnectedVehiclesRoadIllustration extends StatelessWidget {
  const _ConnectedVehiclesRoadIllustration();

  @override
  Widget build(BuildContext context) {
    const double circleSize = 230;
    const Color paleOrange = Color(0xFFFFF0EB);
    const Color orangeAccent = Color(0xFFE45D3F);
    const Color navyDark = Color(0xFF1E293B);

    return SizedBox(
      width: 280,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft pale-orange circular background
          Container(
            width: circleSize,
            height: circleSize,
            decoration: const BoxDecoration(
              color: paleOrange,
              shape: BoxShape.circle,
            ),
          ),

          // Custom Painter for Road and Inter-Vehicle Wireless Signals
          CustomPaint(
            size: const Size(280, 240),
            painter: _RoadAndNetworkPainter(color: orangeAccent),
          ),

          // Vehicle 1: Lead Car (Top Right)
          Positioned(
            top: 45,
            right: 48,
            child: _buildCarBadge(
              icon: Icons.directions_car_filled_rounded,
              color: navyDark,
              borderColor: orangeAccent,
            ),
          ),

          // Vehicle 2: Center Main Vehicle
          Positioned(
            top: 95,
            left: 105,
            child: _buildCarBadge(
              icon: Icons.directions_car_rounded,
              color: orangeAccent,
              borderColor: orangeAccent,
              size: 48,
              iconSize: 26,
              hasShadow: true,
            ),
          ),

          // Vehicle 3: Trailing Car (Bottom Left)
          Positioned(
            bottom: 45,
            left: 45,
            child: _buildCarBadge(
              icon: Icons.directions_car_outlined,
              color: navyDark,
              borderColor: orangeAccent.withValues(alpha: 0.5),
            ),
          ),

          // Vehicle 4: Adjacent Lane Car (Bottom Right)
          Positioned(
            bottom: 50,
            right: 42,
            child: _buildCarBadge(
              icon: Icons.directions_car_filled_rounded,
              color: navyDark,
              borderColor: orangeAccent.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarBadge({
    required IconData icon,
    required Color color,
    required Color borderColor,
    double size = 38,
    double iconSize = 20,
    bool hasShadow = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: const Color(0xFFE45D3F).withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}

/// Custom Painter drawing the clean road perspective and wireless signals between cars
class _RoadAndNetworkPainter extends CustomPainter {
  final Color color;

  _RoadAndNetworkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw Clean Road Lines
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    // Perspective Road edges
    final pathRoadLeft = Path()
      ..moveTo(30, size.height - 25)
      ..lineTo(size.width - 50, 35);
    canvas.drawPath(pathRoadLeft, roadPaint);

    final pathRoadRight = Path()
      ..moveTo(70, size.height - 15)
      ..lineTo(size.width - 20, 50);
    canvas.drawPath(pathRoadRight, roadPaint);

    // Dashed center lane
    final dashPath = Path()
      ..moveTo(50, size.height - 20)
      ..lineTo(size.width - 35, 42);
    canvas.drawPath(dashPath, dashPaint);

    // 2. Draw Inter-Vehicle Wireless Signals (V2V arcs & network nodes)
    final signalPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Node coordinates (Center points of cars)
    const p1 = Offset(212, 64);   // Top Right Car
    const p2 = Offset(129, 119);  // Center Main Car
    const p3 = Offset(64, 171);   // Bottom Left Car
    const p4 = Offset(218, 166);  // Bottom Right Car

    // Wireless Arcs between vehicles
    final arc1 = Path()
      ..moveTo(p3.dx, p3.dy)
      ..quadraticBezierTo(
        (p3.dx + p2.dx) / 2 - 15,
        (p3.dy + p2.dy) / 2 - 25,
        p2.dx,
        p2.dy,
      );
    canvas.drawPath(arc1, signalPaint);

    final arc2 = Path()
      ..moveTo(p2.dx, p2.dy)
      ..quadraticBezierTo(
        (p2.dx + p1.dx) / 2 - 10,
        (p2.dy + p1.dy) / 2 - 25,
        p1.dx,
        p1.dy,
      );
    canvas.drawPath(arc2, signalPaint);

    final arc3 = Path()
      ..moveTo(p2.dx, p2.dy)
      ..quadraticBezierTo(
        (p2.dx + p4.dx) / 2 + 20,
        (p2.dy + p4.dy) / 2 - 10,
        p4.dx,
        p4.dy,
      );
    canvas.drawPath(arc3, signalPaint);

    // Connection Node Dots along signal paths
    canvas.drawCircle(const Offset(92, 126), 3.2, dotPaint);
    canvas.drawCircle(const Offset(168, 76), 3.2, dotPaint);
    canvas.drawCircle(const Offset(185, 138), 3.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🛡️ Screen 2 Illustration: AI Threat Detection & Suspicious Vehicle Scanning
class _AiDetectionIllustration extends StatelessWidget {
  const _AiDetectionIllustration();

  @override
  Widget build(BuildContext context) {
    const double circleSize = 230;
    const Color paleOrange = Color(0xFFFFF0EB);
    const Color orangeAccent = Color(0xFFE45D3F);
    const Color warningRed = Color(0xFFEF4444);
    const Color navyDark = Color(0xFF1E293B);

    return SizedBox(
      width: 290,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft pale-orange circular background
          Container(
            width: circleSize,
            height: circleSize,
            decoration: const BoxDecoration(
              color: paleOrange,
              shape: BoxShape.circle,
            ),
          ),

          // Custom Painter for scanning circle & data analysis node lines
          CustomPaint(
            size: const Size(290, 250),
            painter: _AiScanningNetworkPainter(
              scanColor: orangeAccent,
              warningColor: warningRed,
            ),
          ),

          // Normal Trusted Vehicle (Top Left)
          Positioned(
            top: 40,
            left: 36,
            child: _buildSmallCarBadge(navyDark),
          ),

          // Normal Trusted Vehicle (Top Right)
          Positioned(
            top: 48,
            right: 40,
            child: _buildSmallCarBadge(navyDark),
          ),

          // Normal Trusted Vehicle (Bottom Left)
          Positioned(
            bottom: 45,
            left: 42,
            child: _buildSmallCarBadge(navyDark),
          ),

          // Suspicious Highlighted Vehicle (Center)
          Positioned(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: warningRed, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: warningRed.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                size: 34,
                color: warningRed,
              ),
            ),
          ),

          // Floating White Rounded Card: AI Detection / Suspicious Vehicle
          Positioned(
            bottom: 12,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF3F4F6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: orangeAccent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.memory_rounded,
                          size: 13,
                          color: orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AI Detection',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: warningRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Suspicious Vehicle',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: navyDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCarBadge(Color color) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
      ),
      child: Icon(Icons.directions_car_outlined, size: 18, color: color),
    );
  }
}

class _AiScanningNetworkPainter extends CustomPainter {
  final Color scanColor;
  final Color warningColor;

  _AiScanningNetworkPainter({
    required this.scanColor,
    required this.warningColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final scanPaint = Paint()
      ..color = warningColor.withValues(alpha: 0.25)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final scanOuterPaint = Paint()
      ..color = scanColor.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 44, scanPaint);
    canvas.drawCircle(center, 62, scanOuterPaint);

    final dotPaint = Paint()
      ..color = scanColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx + 44, center.dy), 3.0, dotPaint);
    canvas.drawCircle(Offset(center.dx - 44, center.dy), 3.0, dotPaint);
    canvas.drawCircle(Offset(center.dx, center.dy - 44), 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🧠 Screen 3 Illustration: Explainable AI & Vehicle Trust Score Management
class _SecureTrustIllustration extends StatelessWidget {
  const _SecureTrustIllustration();

  @override
  Widget build(BuildContext context) {
    const double circleSize = 230;
    const Color paleOrange = Color(0xFFFFF0EB);
    const Color orangeAccent = Color(0xFFE45D3F);
    const Color navyDark = Color(0xFF1E293B);

    return SizedBox(
      width: 300,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft pale-orange circular background
          Container(
            width: circleSize,
            height: circleSize,
            decoration: const BoxDecoration(
              color: paleOrange,
              shape: BoxShape.circle,
            ),
          ),

          // Central Vehicle Being Analyzed
          Positioned(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: orangeAccent, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: orangeAccent.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                size: 38,
                color: orangeAccent,
              ),
            ),
          ),

          // Circular Trust Score Indicator Badge ("78% Trust Score")
          Positioned(
            top: 20,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: orangeAccent.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.78,
                          strokeWidth: 3.2,
                          backgroundColor: orangeAccent.withValues(alpha: 0.15),
                          color: orangeAccent,
                        ),
                        Text(
                          '78%',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: navyDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Trust Score',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: navyDark,
                        ),
                      ),
                      Text(
                        'Dynamic Bayesian',
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Explanation Card ("Why Suspicious?")
          Positioned(
            top: 25,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF3F4F6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.help_outline_rounded, size: 13, color: orangeAccent),
                      const SizedBox(width: 4),
                      Text(
                        'Why Suspicious?',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: navyDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildExplanationPoint('Abnormal Speed'),
                  _buildExplanationPoint('Position Inconsistency'),
                  _buildExplanationPoint('Unusual Messages'),
                ],
              ),
            ),
          ),

          // Floating AI Confidence Badge ("AI Confidence 94%")
          Positioned(
            bottom: 22,
            right: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: orangeAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AI Confidence',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '94%',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: navyDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFE45D3F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


