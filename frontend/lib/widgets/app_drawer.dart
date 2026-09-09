import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/shared/authentication/presentation/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.isAdmin;
    final userEmail = authState.email ?? (isAdmin ? 'admin@vanet.com' : 'driver@vanet.com');
    final userName = isAdmin ? 'Admin Operator' : 'Vehicle Driver (V101)';
    final roleBadge = isAdmin ? 'ADMIN' : 'DRIVER NODE';

    return Drawer(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            // 🔹 Profile Header (Role-Aware)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  bottom: BorderSide(color: AppTheme.border, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: (isAdmin ? AppTheme.primary : const Color(0xFF2563EB)).withValues(alpha: 0.15),
                    child: Icon(
                      isAdmin ? Icons.shield_rounded : Icons.directions_car_rounded,
                      color: isAdmin ? AppTheme.primary : const Color(0xFF2563EB),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isAdmin ? AppTheme.primary : const Color(0xFF2563EB)).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            roleBadge,
                            style: GoogleFonts.outfit(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? AppTheme.primary : const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/profile/edit');
                    },
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),
            ),

            // 🔹 Navigation Links List (Role-Specific)
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                children: [
                  if (isAdmin) ...[
                    // 🛡️ ADMIN SPECIFIC DRAWER OPTIONS
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.alt_route_rounded,
                      title: 'Routes & Detours',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/emergency/route');
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.psychology_outlined,
                      title: 'AI Explanations (SHAP & LIME)',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/vehicles/V1023/explanation');
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.shield_outlined,
                      title: 'Dynamic Trust Engine',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/trust');
                      },
                    ),
                  ] else ...[
                    // 🚗 USER / DRIVER SPECIFIC DRAWER OPTIONS
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.alt_route_rounded,
                      title: 'Emergency Priority Routes',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/emergency/route');
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.history_rounded,
                      title: 'My Trust Score History',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/trust/history/V101');
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.warning_amber_rounded,
                      title: 'Accident Advisory',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/alerts/accident');
                      },
                    ),
                  ],

                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  const Divider(height: 20),
                  // 🔹 FYP Demo Role Switcher
                  ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    leading: const Icon(Icons.directions_car_rounded, color: Color(0xFF2563EB), size: 20),
                    title: Text(
                      'Switch to Driver OBU App',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF2563EB),
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Demo switch to Personal Safety Cockpit', style: GoogleFonts.outfit(fontSize: 10.5, color: AppTheme.textSecondary)),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(authProvider.notifier).login('driver@vanet.com', 'driver123', role: 'Driver');
                      context.go('/driver/dashboard');
                    },
                  ),
                ],
              ),
            ),

            // 🔹 Logout Option (Bottom)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.border, width: 1.0),
                ),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
                title: Text(
                  'Logout',
                  style: GoogleFonts.outfit(
                    color: AppTheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Icon(icon, color: AppTheme.textPrimary, size: 20),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppTheme.textPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
