import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';

class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
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
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
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
            indicatorColor: AppTheme.primary.withValues(alpha: 0.14),
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
