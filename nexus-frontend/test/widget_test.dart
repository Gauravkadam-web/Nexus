import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_frontend/app.dart';
import 'package:nexus_frontend/core/widgets/responsive_layout.dart';

void main() {
  testWidgets('NexusApp smoke test builds cleanly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: NexusApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(NexusApp), findsOneWidget);
  });

  testWidgets('LoginScreen renders email, password inputs and quick demo chips', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: NexusApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('1-Click Quick Test Access:'), findsOneWidget);
    expect(find.text('Requester'), findsWidgets);
    expect(find.text('Operator'), findsWidgets);
    expect(find.text('Admin'), findsWidgets);
  });

  testWidgets('ResponsiveLayout adapts to mobile and desktop viewports', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844); // Mobile portrait
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveLayout(
            mobileBody: Text('Mobile Content'),
            desktopBody: Text('Desktop Content'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Mobile Content'), findsOneWidget);
    expect(find.text('Desktop Content'), findsNothing);
  });
}
