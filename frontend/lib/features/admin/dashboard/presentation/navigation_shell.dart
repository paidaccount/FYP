import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/core/utils/responsive.dart';

class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    if (isWide) {
      // 🔹 Responsive Desktop / Tablet Layout with Left Navigation Rail
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(right: BorderSide(color: AppTheme.border, width: 1.0)),
              ),
              child: NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                backgroundColor: AppTheme.surface,
                minWidth: 72,
                minExtendedWidth: 200,
                elevation: 0,
                indicatorColor: AppTheme.primary.withValues(alpha: 0.16),
                labelType: NavigationRailLabelType.all,
                selectedLabelTextStyle: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
                unselectedLabelTextStyle: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 24),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary, size: 22),
                    selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary, size: 22),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.directions_car_outlined, color: AppTheme.textSecondary, size: 22),
                    selectedIcon: Icon(Icons.directions_car_rounded, color: AppTheme.primary, size: 22),
                    label: Text('Vehicles'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary, size: 22),
                    selectedIcon: Icon(Icons.notifications_active_rounded, color: AppTheme.warning, size: 22),
                    label: Text('Alerts'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.local_hospital_outlined, color: AppTheme.textSecondary, size: 22),
                    selectedIcon: Icon(Icons.local_hospital_rounded, color: AppTheme.primary, size: 22),
                    label: Text('Emergency'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.article_outlined, color: AppTheme.textSecondary, size: 22),
                    selectedIcon: Icon(Icons.article_rounded, color: AppTheme.primary, size: 22),
                    label: Text('Reports'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
                  child: navigationShell,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 🔹 Responsive Mobile Layout with Bottom Navigation Bar
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.border,
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                );
              }
              return GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary.withValues(alpha: 0.16),
            elevation: 0,
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary, size: 22),
                selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary, size: 22),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_car_outlined, color: AppTheme.textSecondary, size: 22),
                selectedIcon: Icon(Icons.directions_car_rounded, color: AppTheme.primary, size: 22),
                label: 'Vehicles',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary, size: 22),
                selectedIcon: Icon(Icons.notifications_active_rounded, color: AppTheme.warning, size: 22),
                label: 'Alerts',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_hospital_outlined, color: AppTheme.textSecondary, size: 22),
                selectedIcon: Icon(Icons.local_hospital_rounded, color: AppTheme.primary, size: 22),
                label: 'Emergency',
              ),
              NavigationDestination(
                icon: Icon(Icons.article_outlined, color: AppTheme.textSecondary, size: 22),
                selectedIcon: Icon(Icons.article_rounded, color: AppTheme.primary, size: 22),
                label: 'Reports',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
