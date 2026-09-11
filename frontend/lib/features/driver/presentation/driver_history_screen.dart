import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_provider.dart';

class DriverHistoryScreen extends ConsumerWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Safety & Alert History', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.safetyHistory.length,
        itemBuilder: (context, index) {
          final item = state.safetyHistory[index];
          final isSafe = item['type'] == 'safe';
          final isWarning = item['type'] == 'warning';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isSafe
                      ? AppTheme.safe.withValues(alpha: 0.12)
                      : isWarning
                          ? AppTheme.warning.withValues(alpha: 0.12)
                          : AppTheme.primary.withValues(alpha: 0.12),
                  child: Icon(
                    isSafe
                        ? Icons.check_circle_outline_rounded
                        : isWarning
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline_rounded,
                    color: isSafe
                        ? AppTheme.safe
                        : isWarning
                            ? AppTheme.warning
                            : AppTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['title'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text(item['time'] as String, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item['detail'] as String, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
