import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_frontend/app.dart';

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
  });

  testWidgets('Requester demo login navigates to Requester Portal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: NexusApp(),
      ),
    );
    await tester.pump();

    final reqChip = find.text('Requester').first;
    await tester.tap(reqChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Report a Case'), findsOneWidget);
  });

  testWidgets('Operator demo login navigates to Triage Workstation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: NexusApp(),
      ),
    );
    await tester.pump();

    final opChip = find.text('Operator').first;
    await tester.tap(opChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Cases / Workstation'), findsWidgets);
  });

  testWidgets('Admin demo login navigates to Admin Management', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: NexusApp(),
      ),
    );
    await tester.pump();

    final adminChip = find.text('Admin').first;
    await tester.tap(adminChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Admin Governance'), findsWidgets);
  });
}
