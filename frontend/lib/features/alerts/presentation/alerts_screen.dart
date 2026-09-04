import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

final activeAlertFilterProvider = StateProvider<String>((ref) => 'All');

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(activeAlertFilterProvider);

    // Mockup 4 standard alerts list + live state alerts
    final defaultAlerts = [
      {
        'id': 'ALT-101',
        'title': 'Malicious vehicle detected',
        'time': '10:24 AM',
        'subtitle': 'Vehicle ID: V1023',
        'category': 'Security',
        'type': 'malicious',
        'color': AppTheme.error,
        'icon': Icons.shield_outlined,
        'route': '/vehicles/V1023/explanation',
      },
      {
        'id': 'ALT-102',
        'title': 'Fake emergency message detected',
        'time': '10:21 AM',
        'subtitle': 'Vehicle ID: V2055',
        'category': 'Security',
        'type': 'fake_emergency',
        'color': AppTheme.warning,
        'icon': Icons.warning_amber_rounded,
        'route': '/vehicles/V2055',
      },
      {
        'id': 'ALT-103',
        'title': 'Emergency vehicle approaching',
        'time': '10:20 AM',
        'subtitle': 'Ambulance • 1.2 km away',
        'category': 'Emergency',
        'type': 'emergency_approaching',
        'color': const Color(0xFF2563EB),
        'icon': Icons.local_hospital_outlined,
        'route': '/emergency',
      },
      {
        'id': 'ALT-104',
        'title': 'Accident ahead',
        'time': '10:18 AM',
        'subtitle': 'Road A - Sector 12',
        'category': 'Traffic',
        'type': 'accident',
        'color': AppTheme.primary,
        'icon': Icons.warning_amber_rounded,
        'route': '/alerts/accident',
      },
      {
        'id': 'ALT-105',
        'title': 'Heavy traffic ahead',
        'time': '10:15 AM',
        'subtitle': 'Road B - Sector 5',
        'category': 'Traffic',
        'type': 'traffic',
        'color': AppTheme.primary,
        'icon': Icons.traffic_rounded,
        'route': '/emergency/route',
      },
    ];

    // Filter alerts based on chip selection
    final filteredList = defaultAlerts.where((item) {
      if (activeFilter == 'All') return true;
      return item['category'] == activeFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Live Alerts',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppTheme.textPrimary, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Filtering active stream by severity and incident type',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Horizontal Filter Chips Row (Matching Mockup 4)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(ref, 'All', activeFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip(ref, 'Security', activeFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip(ref, 'Emergency', activeFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip(ref, 'Traffic', activeFilter),
                ],
              ),
            ),
          ),
          const Divider(color: AppTheme.border, height: 1),

          // 🔹 Alerts List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alert = filteredList[index];
                return _buildAlertCard(context, alert);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String activeFilter) {
    final isSelected = activeFilter == label;

    return InkWell(
      onTap: () => ref.read(activeAlertFilterProvider.notifier).state = label,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, dynamic> alert) {
    final Color iconColor = alert['color'] as Color;
    final IconData iconData = alert['icon'] as IconData;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final route = alert['route'] as String?;
            if (route != null) {
              context.push(route);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert['subtitle'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Timestamp
                Text(
                  alert['time'] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
