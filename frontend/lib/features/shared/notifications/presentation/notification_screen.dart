import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/shared/notifications/presentation/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(notificationProvider);
    
    // Apply categories filters
    final filteredList = selectedFilter == 'ALL'
        ? list
        : list.where((item) => item['notification_type'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'BROADCAST NOTIFICATIONS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 20),
            onPressed: () => ref.read(notificationProvider.notifier).loadHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All Broadcasts'),
                const SizedBox(width: 6),
                _buildFilterChip('SECURITY', 'Security Alerts'),
                const SizedBox(width: 6),
                _buildFilterChip('EMERGENCY', 'Priority Sirens'),
                const SizedBox(width: 6),
                _buildFilterChip('TRAFFIC', 'Detour Routes'),
                const SizedBox(width: 6),
                _buildFilterChip('TRUST', 'Trust Decay'),
              ],
            ),
          ),
          
          // History items list view
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 44,
                            color: AppTheme.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No broadcast notifications found.',
                            style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final active = (selectedFilter == key);
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = key;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? AppTheme.primary : AppTheme.border,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: active ? Colors.white : AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final isRead = item['is_read'] as bool? ?? false;
    final type = item['notification_type'] as String? ?? 'TRAFFIC';
    
    Color typeColor;
    IconData typeIcon;
    switch (type) {
      case 'SECURITY':
        typeColor = AppTheme.error;
        typeIcon = Icons.gpp_bad_outlined;
        break;
      case 'EMERGENCY':
        typeColor = AppTheme.warning;
        typeIcon = Icons.local_hospital_outlined;
        break;
      case 'TRUST':
        typeColor = AppTheme.safe;
        typeIcon = Icons.verified_user_outlined;
        break;
      default:
        typeColor = AppTheme.primary;
        typeIcon = Icons.traffic_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.controlCardDecoration(
        borderColor: isRead ? AppTheme.border : typeColor.withValues(alpha: 0.4),
        surfaceColor: AppTheme.surface,
        radius: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: typeColor.withValues(alpha: 0.25)),
            ),
            child: Icon(typeIcon, color: typeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? 'Notification Broadcast',
                  style: GoogleFonts.outfit(
                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['message'] ?? '',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['created_at']?.split('T')?.first ?? 'Today',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: AppTheme.textSecondary, size: 18),
              tooltip: 'Mark as read',
              onPressed: () {
                ref.read(notificationProvider.notifier).markAsRead(item['id']);
              },
            ),
        ],
      ),
    );
  }
}
