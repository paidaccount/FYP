import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_provider.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverProvider);
    final driverNotifier = ref.read(driverProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 1. In-Vehicle Cockpit Telemetry Card (Speed & OBU)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.safe,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'V2X OBU BROADCASTING',
                            style: GoogleFonts.outfit(
                              color: AppTheme.safe,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: ${driverState.vehicleId}',
                          style: GoogleFonts.outfit(
                            color: AppTheme.primary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Speed Meter
                      Column(
                        children: [
                          Text(
                            '${driverState.currentSpeed.toInt()}',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'KM / H',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 48, width: 1, color: AppTheme.border),
                      // Trust Rating Gauge
                      Column(
                        children: [
                          Text(
                            '${(driverState.trustScore * 100).toInt()}%',
                            style: GoogleFonts.outfit(
                              color: AppTheme.primary,
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'TRUST HEALTH',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Emergency Mode Beacon Switch
                  InkWell(
                    onTap: () => driverNotifier.toggleEmergencyMode(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: driverState.isEmergencyModeActive
                            ? AppTheme.error
                            : AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: driverState.isEmergencyModeActive
                              ? AppTheme.error
                              : AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            driverState.isEmergencyModeActive
                                ? Icons.warning_amber_rounded
                                : Icons.emergency_rounded,
                            color: driverState.isEmergencyModeActive ? Colors.white : AppTheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            driverState.isEmergencyModeActive
                                ? 'EMERGENCY PREEMPTION ACTIVE'
                                : 'ACTIVATE EMERGENCY PRIORITY BEACON',
                            style: GoogleFonts.outfit(
                              color: driverState.isEmergencyModeActive ? Colors.white : AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 2. Priority Safety Alert Banner (If Any)
            if (driverState.activeAlerts.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverState.activeAlerts.first.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            driverState.activeAlerts.first.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(fontSize: 11.5, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onPressed: () => context.push('/driver/alerts'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 🔹 3. Quick Action Grid (10 Module Access)
            Text(
              'Personal Safety & Assist Modules',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                _buildActionCard(
                  context,
                  title: 'Nearby Radar',
                  subtitle: '${driverState.nearbyVehicles.length} vehicles detected',
                  icon: Icons.radar_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () => context.push('/driver/nearby'),
                ),
                _buildActionCard(
                  context,
                  title: 'Safe Route (A*)',
                  subtitle: 'Fast, secure corridor',
                  icon: Icons.alt_route_rounded,
                  color: const Color(0xFF059669),
                  onTap: () => context.push('/driver/safe-route'),
                ),
                _buildActionCard(
                  context,
                  title: 'AI Explanation',
                  subtitle: 'Plain XAI breakdown',
                  icon: Icons.psychology_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: () => context.push('/driver/xai/V1023'),
                ),
                _buildActionCard(
                  context,
                  title: 'Emergency Siren',
                  subtitle: 'Preemption clearance',
                  icon: Icons.emergency_rounded,
                  color: const Color(0xFFDC2626),
                  onTap: () => context.push('/driver/emergency'),
                ),
                _buildActionCard(
                  context,
                  title: 'Road Hazards',
                  subtitle: 'Slippery & crash alerts',
                  icon: Icons.car_crash_rounded,
                  color: const Color(0xFFD97706),
                  onTap: () => context.push('/driver/hazards'),
                ),
                _buildActionCard(
                  context,
                  title: 'My Vehicle Info',
                  subtitle: 'OBU & trust stats',
                  icon: Icons.directions_car_rounded,
                  color: const Color(0xFF475569),
                  onTap: () => context.push('/driver/my-vehicle'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 4. Nearby Vehicles Glance List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Surrounding V2V Nodes',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/driver/nearby'),
                  child: Text(
                    'View Radar',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: driverState.nearbyVehicles.take(3).length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final vehicle = driverState.nearbyVehicles[index];
                final isUntrusted = vehicle.trustStatus == 'Untrusted';
                final isEmergency = vehicle.isEmergency;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUntrusted ? AppTheme.error.withValues(alpha: 0.3) : AppTheme.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEmergency
                              ? AppTheme.error.withValues(alpha: 0.12)
                              : isUntrusted
                                  ? AppTheme.error.withValues(alpha: 0.1)
                                  : AppTheme.safe.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEmergency
                              ? Icons.emergency_rounded
                              : isUntrusted
                                  ? Icons.warning_amber_rounded
                                  : Icons.directions_car_rounded,
                          color: isEmergency
                              ? AppTheme.error
                              : isUntrusted
                                  ? AppTheme.error
                                  : AppTheme.safe,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  vehicle.id,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                                if (isEmergency) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppTheme.error,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'PRIORITY',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'Speed: ${vehicle.speed.toInt()} km/h • Trust: ${(vehicle.trustScore * 100).toInt()}%',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUntrusted)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error,
                            side: const BorderSide(color: AppTheme.error),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          onPressed: () => context.push('/driver/xai/${vehicle.id}'),
                          child: Text('Why?', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.textSecondary),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
