import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/admin/dashboard/presentation/dashboard_provider.dart';

final vehiclesSearchQueryProvider = StateProvider<String>((ref) => '');

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final searchQuery = ref.watch(vehiclesSearchQueryProvider);

    // Mockup 5 fallback items + live backend vehicles
    final defaultMockVehicles = [
      {'id': 'V101', 'score': 95, 'status': 'Trusted', 'color': AppTheme.safe},
      {'id': 'V102', 'score': 68, 'status': 'Suspicious', 'color': AppTheme.warning},
      {'id': 'V103', 'score': 28, 'status': 'Untrusted', 'color': AppTheme.error},
      {'id': 'V104', 'score': 85, 'status': 'Trusted', 'color': AppTheme.safe},
      {'id': 'V105', 'score': 55, 'status': 'Suspicious', 'color': AppTheme.warning},
      {'id': 'V106', 'score': 32, 'status': 'Untrusted', 'color': AppTheme.error},
      {'id': 'V107', 'score': 91, 'status': 'Trusted', 'color': AppTheme.safe},
      {'id': 'V108', 'score': 47, 'status': 'Suspicious', 'color': AppTheme.warning},
    ];

    // Combine live vehicles if available, otherwise use mock list
    final vehicleList = state.vehicles.isNotEmpty
        ? state.vehicles.map((v) {
            final isTrusted = v.trustStatus.toLowerCase() == 'trusted';
            final isSuspicious = v.trustStatus.toLowerCase() == 'suspicious';
            final color = isTrusted ? AppTheme.safe : (isSuspicious ? AppTheme.warning : AppTheme.error);
            return {
              'id': v.id,
              'score': v.trustScore.toInt(),
              'status': isTrusted ? 'Trusted' : (isSuspicious ? 'Suspicious' : 'Untrusted'),
              'color': color,
            };
          }).toList()
        : defaultMockVehicles;

    final filteredVehicles = vehicleList.where((v) {
      final id = v['id'] as String;
      return id.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Vehicle Trust Ranking',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Search Box (Matching Mockup 5)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                onChanged: (val) => ref.read(vehiclesSearchQueryProvider.notifier).state = val,
                style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Search Vehicle ID',
                  hintStyle: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, size: 19, color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),
          const Divider(color: AppTheme.border, height: 1),

          // 🔹 Table Header (Matching Mockup 5)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Vehicle ID',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'Trust Score',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Status',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.border, height: 1),

          // 🔹 Vehicles Table Rows
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredVehicles.length,
              separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
              itemBuilder: (context, index) {
                final item = filteredVehicles[index];
                final id = item['id'] as String;
                final score = item['score'] as int;
                final status = item['status'] as String;
                final color = item['color'] as Color;

                return InkWell(
                  onTap: () {
                    // Navigate to details or explanation
                    context.push('/vehicles/$id/explanation');
                  },
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                    child: Row(
                      children: [
                        // Vehicle ID
                        Expanded(
                          flex: 3,
                          child: Text(
                            id,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),

                        // Trust Score
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              score.toString(),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),

                        // Status Pill Badge
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.outfit(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
