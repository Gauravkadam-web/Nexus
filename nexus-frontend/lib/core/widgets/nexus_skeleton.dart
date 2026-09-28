import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context_extensions.dart';

/// Smooth animated shimmer pulsing container for zero-layout-shift (CLS) states.
class NexusShimmerEffect extends StatefulWidget {
  final Widget child;

  const NexusShimmerEffect({super.key, required this.child});

  @override
  State<NexusShimmerEffect> createState() => _NexusShimmerEffectState();
}

class _NexusShimmerEffectState extends State<NexusShimmerEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// A token-styled placeholder block simulating text or visual elements.
class NexusSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const NexusSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF262C36) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer card simulating a KPI or metric tile.
class NexusSkeletonCard extends StatelessWidget {
  final double height;

  const NexusSkeletonCard({
    super.key,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return NexusShimmerEffect(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NexusSkeletonBox(width: 80, height: 12),
                NexusSkeletonBox(width: 16, height: 16, borderRadius: 8),
              ],
            ),
            NexusSkeletonBox(width: 60, height: 24),
            NexusSkeletonBox(width: 90, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Shimmer table simulating tabular rows to eliminate Cumulative Layout Shift (CLS).
class NexusSkeletonTable extends StatelessWidget {
  final int rowCount;

  const NexusSkeletonTable({
    super.key,
    this.rowCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return NexusShimmerEffect(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border),
        ),
        child: Column(
          children: [
            // Table Header Simulation
            const Row(
              children: [
                NexusSkeletonBox(width: 100, height: 14),
                SizedBox(width: 16),
                Expanded(child: NexusSkeletonBox(height: 14)),
                SizedBox(width: 16),
                NexusSkeletonBox(width: 80, height: 14),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: context.border, height: 1),
            const SizedBox(height: AppSpacing.md),
            // Rows
            ...List.generate(
              rowCount,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const NexusSkeletonBox(width: 80, height: 16),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: NexusSkeletonBox(
                        height: 14,
                        width: (index % 2 == 0) ? null : 160,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const NexusSkeletonBox(width: 64, height: 20, borderRadius: 10),
                    const SizedBox(width: 16),
                    const NexusSkeletonBox(width: 24, height: 24, borderRadius: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer list simulating feed or incident cards.
class NexusSkeletonList extends StatelessWidget {
  final int count;

  const NexusSkeletonList({
    super.key,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    return NexusShimmerEffect(
      child: Column(
        children: List.generate(
          count,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NexusSkeletonBox(width: 90, height: 14),
                      NexusSkeletonBox(width: 60, height: 18, borderRadius: 9),
                    ],
                  ),
                  SizedBox(height: 10),
                  NexusSkeletonBox(width: 220, height: 16),
                  SizedBox(height: 6),
                  NexusSkeletonBox(height: 12),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NexusSkeletonBox(width: 110, height: 12),
                      NexusSkeletonBox(width: 80, height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
