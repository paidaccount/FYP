import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_provider.dart';

class DriverEmergencyScreen extends ConsumerWidget {
  const DriverEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider);
    final notifier = ref.read(driverProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Vehicle Priority', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 1. Emergency Priority Beacon Broadcast Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: state.isEmergencyModeActive
                    ? AppTheme.error
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: state.isEmergencyModeActive ? AppTheme.error : AppTheme.border,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (state.isEmergencyModeActive ? AppTheme.error : Colors.black).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emergency_rounded,
                    size: 48,
                    color: state.isEmergencyModeActive ? Colors.white : AppTheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.isEmergencyModeActive
                        ? 'EMERGENCY BEACON ACTIVE'
                        : 'Emergency Vehicle Priority Mode',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: state.isEmergencyModeActive ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.isEmergencyModeActive
                        ? 'Broadcasting preemption beacon to all RSUs and nearby vehicles. Traffic signals yielding green corridor.'
                        : 'For authorized ambulances, fire trucks, and police units only. Triggers V2I traffic light preemption.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: state.isEmergencyModeActive ? Colors.white.withValues(alpha: 0.9) : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isEmergencyModeActive ? Colors.white : AppTheme.error,
                      foregroundColor: state.isEmergencyModeActive ? AppTheme.error : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => notifier.toggleEmergencyMode(),
                    child: Text(
                      state.isEmergencyModeActive ? 'DEACTIVATE PRIORITY' : 'REQUEST CORRIDOR PRIORITY',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 2. Nearby Approaching Emergency Vehicles Feed
            Text(
              'Approaching Emergency Vehicles',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),

            Container(
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
                          color: AppTheme.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_hospital_rounded, color: AppTheme.error, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rescue 1122 Ambulance (#AMB-1122)',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Approaching 350m behind • Speed: 84 km/h',
                              style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.turn_right_rounded, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Driver Instruction: Please yield lane and merge safely to the right shoulder within 100 meters.',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 3. Preemption Corridor Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('V2I Green-Wave Preemption Status', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _stepRow(1, 'Intersection J-01 (Kashmir Highway)', 'Preempted (Green Light Held)', AppTheme.safe),
                  _stepRow(2, 'Intersection J-02 (7th Avenue)', 'Preempted (Green Light Held)', AppTheme.safe),
                  _stepRow(3, 'Intersection J-03 (Hospital Turn)', 'Syncing (Estimated 45s)', AppTheme.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepRow(int step, String location, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text('$step', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(location, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          Text(status, style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
