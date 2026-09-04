import 'package:flutter/material.dart';

class DashboardSkeleton extends StatefulWidget {
  const DashboardSkeleton({super.key});

  @override
  State<DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<DashboardSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBox({required double height, double width = double.infinity, double borderRadius = 12}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade300.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBox(height: 12, width: 80),
                  const SizedBox(height: 6),
                  _buildBox(height: 20, width: 180),
                ],
              ),
              _buildBox(height: 36, width: 36, borderRadius: 18),
            ],
          ),
          const SizedBox(height: 20),

          // Network Risk Card Skeleton
          _buildBox(height: 125, borderRadius: 16),
          const SizedBox(height: 20),

          // 2x2 Grid Skeleton
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: List.generate(4, (_) => _buildBox(height: 90, borderRadius: 14)),
          ),
          const SizedBox(height: 20),

          // Live Network Skeleton
          _buildBox(height: 20, width: 120),
          const SizedBox(height: 10),
          _buildBox(height: 180, borderRadius: 14),
          const SizedBox(height: 20),

          // Alerts Skeleton
          _buildBox(height: 20, width: 140),
          const SizedBox(height: 10),
          _buildBox(height: 90, borderRadius: 14),
          const SizedBox(height: 10),
          _buildBox(height: 90, borderRadius: 14),
        ],
      ),
    );
  }
}
