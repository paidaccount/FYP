import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vanet_mobile/features/splash/presentation/splash_screen.dart';
import 'package:vanet_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:vanet_mobile/features/authentication/presentation/login_screen.dart';
import 'package:vanet_mobile/features/authentication/presentation/auth_provider.dart';
import 'package:vanet_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:vanet_mobile/features/dashboard/presentation/navigation_shell.dart';
import 'package:vanet_mobile/features/vehicles/presentation/vehicles_screen.dart';
import 'package:vanet_mobile/features/vehicles/presentation/vehicle_details_screen.dart';
import 'package:vanet_mobile/features/vehicles/presentation/ai_detection_screen.dart';
import 'package:vanet_mobile/features/vehicles/presentation/ai_explanation_screen.dart';
import 'package:vanet_mobile/features/trust/presentation/trust_management_screen.dart';
import 'package:vanet_mobile/features/trust/presentation/trust_history_screen.dart';
import 'package:vanet_mobile/features/emergency/presentation/emergency_vehicles_screen.dart';
import 'package:vanet_mobile/features/emergency/presentation/fake_emergency_screen.dart';
import 'package:vanet_mobile/features/emergency/presentation/route_recommendation_screen.dart';
import 'package:vanet_mobile/features/alerts/presentation/alerts_screen.dart';
import 'package:vanet_mobile/features/alerts/presentation/accident_alert_screen.dart';
import 'package:vanet_mobile/features/reports/presentation/security_reports_screen.dart';
import 'package:vanet_mobile/features/settings/presentation/settings_screen.dart';
import 'package:vanet_mobile/features/profile/presentation/profile_screen.dart';
import 'package:vanet_mobile/features/profile/presentation/edit_profile_screen.dart';

import 'package:vanet_mobile/models/vehicle_model.dart';
import 'package:vanet_mobile/models/route_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionDashboardKey = GlobalKey<NavigatorState>();
final _sectionVehiclesKey = GlobalKey<NavigatorState>();
final _sectionAlertsKey = GlobalKey<NavigatorState>();
final _sectionEmergencyKey = GlobalKey<NavigatorState>();
final _sectionReportsKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isPublicRoute = loc == '/splash' || loc == '/onboarding' || loc == '/login';

      if (!authState.isAuthenticated) {
        return isPublicRoute ? null : '/login';
      }
      if (isPublicRoute) {
        return '/dashboard';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // 1. Dashboard Branch
          StatefulShellBranch(
            navigatorKey: _sectionDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 2. Vehicles Branch
          StatefulShellBranch(
            navigatorKey: _sectionVehiclesKey,
            routes: [
              GoRoute(
                path: '/vehicles',
                builder: (context, state) => const VehiclesScreen(),
              ),
            ],
          ),
          // 3. Alerts Branch
          StatefulShellBranch(
            navigatorKey: _sectionAlertsKey,
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
          // 4. Emergency Branch
          StatefulShellBranch(
            navigatorKey: _sectionEmergencyKey,
            routes: [
              GoRoute(
                path: '/emergency',
                builder: (context, state) => const EmergencyVehiclesScreen(),
              ),
            ],
          ),
          // 5. Reports Branch
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
      // 🔹 Secondary Administrative & Detail Routes (Accessible via Drawer & Deep Links)
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
