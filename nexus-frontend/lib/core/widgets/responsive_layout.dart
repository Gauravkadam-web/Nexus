import 'package:flutter/material.dart';

enum DeviceScreenType { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)? mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;
  final Widget? mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;

  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return DeviceScreenType.desktop;
    } else if (width >= 600) {
      return DeviceScreenType.tablet;
    }
    return DeviceScreenType.mobile;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1200;
  }
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          if (desktop != null) return desktop!(context, constraints);
          if (desktopBody != null) return desktopBody!;
        } else if (constraints.maxWidth >= 600) {
          if (tablet != null) return tablet!(context, constraints);
          if (tabletBody != null) return tabletBody!;
          if (desktop != null) return desktop!(context, constraints);
          if (desktopBody != null) return desktopBody!;
        }
        if (mobile != null) return mobile!(context, constraints);
        if (mobileBody != null) return mobileBody!;
        return const SizedBox.shrink();
      },
    );
  }
}
