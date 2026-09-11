import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/colors.dart';
import 'package:vanet_mobile/features/admin/dashboard/presentation/widgets/section_header.dart';

class ActivityItem {
  final String title;
  final String timeAgo;
  final Color dotColor;

  const ActivityItem({
    required this.title,
    required this.timeAgo,
    required this.dotColor,
  });
}

class RecentActivitySection extends StatelessWidget {
  final List<ActivityItem>? customActivities;

  const RecentActivitySection({
    super.key,
    this.customActivities,
  });

  static final List<ActivityItem> _defaultActivities = [
    const ActivityItem(
      title: 'Vehicle V-315 restored to trusted state',
      timeAgo: '2 minutes ago',
      dotColor: AppColors.safe,
    ),
    const ActivityItem(
      title: 'Vehicle V-221 flagged suspicious (Speed Anomaly)',
      timeAgo: '5 minutes ago',
      dotColor: AppColors.warning,
    ),
    const ActivityItem(
      title: 'Position offset attack detected on Sector 4',
      timeAgo: '8 minutes ago',
      dotColor: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activities = customActivities ?? _defaultActivities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Recent Activity'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
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
          child: Column(
            children: List.generate(activities.length, (index) {
              final item = activities[index];
              final isLast = index == activities.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Dot & Vertical Connector Line
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.dotColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: item.dotColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: AppColors.border,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // Activity Text & Time
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.timeAgo,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
