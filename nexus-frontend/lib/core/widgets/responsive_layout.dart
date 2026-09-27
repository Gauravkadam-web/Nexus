import 'package:flutter/material.dart';

/// Centralized responsive layout widget and breakpoint definitions
/// aligned with Nexus Design System specifications.
class ResponsiveLayout extends StatelessWidget {
  final Widget? mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;
  final Widget Function(BuildContext, BoxConstraints)? mobile;
  final Widget Function(BuildContext, BoxConstraints)? tablet;
  final Widget Function(BuildContext, BoxConstraints)? desktop;

  const ResponsiveLayout({
    super.key,
    this.mobileBody,
    this.tabletBody,
    this.desktopBody,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Mobile breakpoint (< 768px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  /// Tablet breakpoint (768px - 1199px)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  /// Desktop breakpoint (>= 1200px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isMob = width < 768;
        final bool isTab = width >= 768 && width < 1200;

        if (isMob) {
          if (mobileBody != null) return mobileBody!;
          if (mobile != null) return mobile!(context, constraints);
          if (desktopBody != null) return desktopBody!;
          if (desktop != null) return desktop!(context, constraints);
        } else if (isTab) {
          if (tabletBody != null) return tabletBody!;
          if (tablet != null) return tablet!(context, constraints);
          if (desktopBody != null) return desktopBody!;
          if (desktop != null) return desktop!(context, constraints);
          if (mobileBody != null) return mobileBody!;
          if (mobile != null) return mobile!(context, constraints);
        } else {
          if (desktopBody != null) return desktopBody!;
          if (desktop != null) return desktop!(context, constraints);
          if (tablet != null) return tablet!(context, constraints);
          if (mobileBody != null) return mobileBody!;
          if (mobile != null) return mobile!(context, constraints);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Type alias so both `Responsive` and `ResponsiveLayout` can be used interchangeably
typedef Responsive = ResponsiveLayout;

/// Helper for rendering 4-column metric rows on Desktop and 2x2 grids on Mobile
class ResponsiveMetricGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveMetricGrid({
    super.key,
    required this.children,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      // 2x2 Grid for Mobile (matching Stitch mobile specs)
      final List<Widget> rows = [];
      for (int i = 0; i < children.length; i += 2) {
        final first = children[i];
        final second = (i + 1 < children.length) ? children[i + 1] : const Spacer();
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              SizedBox(width: spacing),
              Expanded(child: second),
            ],
          ),
        );
        if (i + 2 < children.length) {
          rows.add(SizedBox(height: spacing));
        }
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      );
    } else {
      // Single horizontal row for Desktop
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .asMap()
            .entries
            .map((entry) => [
                  if (entry.key > 0) SizedBox(width: spacing),
                  Expanded(child: entry.value),
                ])
            .expand((e) => e)
            .toList(),
      );
    }
  }
}
