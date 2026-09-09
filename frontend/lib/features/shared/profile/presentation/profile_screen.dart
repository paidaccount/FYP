import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/shared/authentication/presentation/auth_provider.dart';

final profileNameProvider = StateProvider<String>((ref) => "Admin Operator");
final profileEmailProvider = StateProvider<String>((ref) => "admin@vanet.com");

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final String email = authState.email ?? ref.watch(profileEmailProvider);
    final String name = email.startsWith('admin') ? "Admin Operator" : ref.watch(profileNameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          'Profile',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // 🔹 Circular Avatar Container
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 User Name & Role Subtitle
              Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'VANET System Administrator',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              // 🔹 Account Details Heading
              Text(
                'ACCOUNT DETAILS',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                  letterSpacing: 1.0,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              // 🔹 Detail Cards
              _buildDetailCard(
                icon: Icons.alternate_email_rounded,
                label: 'Email Address',
                value: email,
              ),
              const SizedBox(height: 10),
              _buildDetailCard(
                icon: Icons.key_rounded,
                label: 'Operator Node ID',
                value: 'OP-NODE-4089-PK',
              ),
              const SizedBox(height: 10),
              _buildDetailCard(
                icon: Icons.security_rounded,
                label: 'Access Level',
                value: 'Full RSU & Fleet Telemetry Authority',
              ),

              const SizedBox(height: 32),

              // 🔹 Edit Profile Action Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => context.push('/profile/edit'),
                  child: Text(
                    'Edit Profile',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 Log Out Action Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
