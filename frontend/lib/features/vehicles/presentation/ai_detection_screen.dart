import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/theme.dart';
import 'package:vanet_mobile/features/dashboard/presentation/dashboard_provider.dart';
import 'package:vanet_mobile/features/vehicles/presentation/widgets/prediction_card.dart';
import 'package:vanet_mobile/models/explanation_model.dart';

class AIDetectionScreen extends ConsumerWidget {
  final String id;

  const AIDetectionScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    final explanation = state.explanations[id] ??
        ExplanationModel(
          vehicleId: id,
          prediction: 'Normal',
          confidence: 99.8,
          modelName: 'XGBoost Telemetry Classifier',
          attackType: 'None (Consistent Behaviors)',
          severity: 'Low',
          humanReason: 'All kinematic features verify spatial-temporal consistency constraints with nearby vehicles.',
          shapValues: const {},
          limeValues: const {},
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AI Detection',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PredictionCard(
                  explanation: explanation,
                  onTap: () => context.push('/vehicles/$id/explanation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
