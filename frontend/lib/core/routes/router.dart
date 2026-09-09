import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vanet_mobile/features/shared/splash/presentation/splash_screen.dart';
import 'package:vanet_mobile/features/shared/onboarding/presentation/onboarding_screen.dart';
import 'package:vanet_mobile/features/shared/authentication/presentation/login_screen.dart';
import 'package:vanet_mobile/features/shared/authentication/presentation/auth_provider.dart';

// 🛡️ Admin Shell & Screens
import 'package:vanet_mobile/features/admin/dashboard/presentation/dashboard_screen.dart';
import 'package:vanet_mobile/features/admin/dashboard/presentation/navigation_shell.dart';
import 'package:vanet_mobile/features/admin/vehicles/presentation/vehicles_screen.dart';
import 'package:vanet_mobile/features/admin/vehicles/presentation/vehicle_details_screen.dart';
import 'package:vanet_mobile/features/admin/vehicles/presentation/ai_detection_screen.dart';
import 'package:vanet_mobile/features/admin/vehicles/presentation/ai_explanation_screen.dart';
import 'package:vanet_mobile/features/admin/trust/presentation/trust_management_screen.dart';
import 'package:vanet_mobile/features/admin/trust/presentation/trust_history_screen.dart';
import 'package:vanet_mobile/features/admin/emergency/presentation/emergency_vehicles_screen.dart';
import 'package:vanet_mobile/features/admin/emergency/presentation/fake_emergency_screen.dart';
import 'package:vanet_mobile/features/admin/emergency/presentation/route_recommendation_screen.dart';
import 'package:vanet_mobile/features/admin/alerts/presentation/alerts_screen.dart';
import 'package:vanet_mobile/features/admin/alerts/presentation/accident_alert_screen.dart';
import 'package:vanet_mobile/features/admin/reports/presentation/security_reports_screen.dart';
import 'package:vanet_mobile/features/shared/settings/presentation/settings_screen.dart';
import 'package:vanet_mobile/features/shared/profile/presentation/profile_screen.dart';
import 'package:vanet_mobile/features/shared/profile/presentation/edit_profile_screen.dart';

// 🚗 Driver / User Shell & Screens
import 'package:vanet_mobile/features/driver/presentation/driver_navigation_shell.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_dashboard_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/nearby_vehicles_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_alerts_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_map_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/my_vehicle_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_xai_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_emergency_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_hazards_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_safe_route_screen.dart';
import 'package:vanet_mobile/features/driver/presentation/driver_history_screen.dart';

import 'package:vanet_mobile/models/vehicle_model.dart';
import 'package:vanet_mobile/models/route_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Admin Shell Keys
final _sectionDashboardKey = GlobalKey<NavigatorState>();
final _sectionVehiclesKey = GlobalKey<NavigatorState>();
final _sectionAlertsKey = GlobalKey<NavigatorState>();
final _sectionEmergencyKey = GlobalKey<NavigatorState>();
final _sectionReportsKey = GlobalKey<NavigatorState>();

// Driver Shell Keys
final _driverDashboardKey = GlobalKey<NavigatorState>();
final _driverRadarKey = GlobalKey<NavigatorState>();
final _driverAlertsKey = GlobalKey<NavigatorState>();
final _driverMapKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // 1. Initial Cold Start: Allow /splash strictly while not completed
      if (!authState.hasCompletedSplash) {
        return loc == '/splash' ? null : '/splash';
      }

      // 2. Once splash completed: NEVER go back to /splash
      if (loc == '/splash') {
        if (!authState.isAuthenticated) {
          return authState.hasSeenOnboarding ? '/login' : '/onboarding';
        }
        return authState.isAdmin ? '/dashboard' : '/driver/dashboard';
      }

      // 3. If unauthenticated
      if (!authState.isAuthenticated) {
        if (loc == '/login' || loc == '/onboarding') {
          return null;
        }
        return authState.hasSeenOnboarding ? '/login' : '/onboarding';
      }

      // 4. If authenticated and accessing auth/public routes
      if (loc == '/login' || loc == '/onboarding') {
        return authState.isAdmin ? '/dashboard' : '/driver/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ==========================================
      // 🛡️ 1. ADMIN APP NAVIGATION SHELL
      // ==========================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _sectionDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionVehiclesKey,
            routes: [
              GoRoute(
                path: '/vehicles',
                builder: (context, state) => const VehiclesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionAlertsKey,
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionEmergencyKey,
            routes: [
              GoRoute(
                path: '/emergency',
                builder: (context, state) => const EmergencyVehiclesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionReportsKey,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const SecurityReportsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ==========================================
      // 🚗 2. DRIVER / USER APP NAVIGATION SHELL
      // ==========================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DriverNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _driverDashboardKey,
            routes: [
              GoRoute(
                path: '/driver/dashboard',
                builder: (context, state) => const DriverDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _driverRadarKey,
            routes: [
              GoRoute(
                path: '/driver/nearby',
                builder: (context, state) => const NearbyVehiclesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _driverAlertsKey,
            routes: [
              GoRoute(
                path: '/driver/alerts',
                builder: (context, state) => const DriverAlertsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _driverMapKey,
            routes: [
              GoRoute(
                path: '/driver/map',
                builder: (context, state) => const DriverMapScreen(),
              ),
            ],
          ),
        ],
      ),

      // ==========================================
      // 🚗 DRIVER SECONDARY & DETAIL ROUTES
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/driver/my-vehicle',
        builder: (context, state) => const MyVehicleScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/driver/xai/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'V1023';
          return DriverXAIScreen(vehicleId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/driver/emergency',
        builder: (context, state) => const DriverEmergencyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/driver/hazards',
        builder: (context, state) => const DriverHazardsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/driver/safe-route',
        builder: (context, state) => const DriverSafeRouteScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/driver/history',
        builder: (context, state) => const DriverHistoryScreen(),
      ),

      // ==========================================
      // 🛡️ ADMIN SECONDARY & DETAIL ROUTES
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/trust',
        builder: (context, state) => const TrustManagementScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/trust/history/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'V1023';
          return TrustHistoryScreen(vehicleId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/vehicles/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VehicleDetailsScreen(id: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/vehicles/:id/detection',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AIDetectionScreen(id: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/vehicles/:id/explanation',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AIExplanationScreen(id: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/emergency/fake',
        builder: (context, state) {
          final vehicle = state.extra as VehicleModel?;
          if (vehicle == null) {
            return const EmergencyVehiclesScreen();
          }
          return FakeEmergencyScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/emergency/route',
        builder: (context, state) {
          final route = state.extra as RouteModel?;
          return RouteRecommendationScreen(route: route);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/alerts/accident',
        builder: (context, state) => const AccidentAlertScreen(),
      ),
    ],
  );
});
