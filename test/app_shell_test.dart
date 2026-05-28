import 'package:beyond_peaks/app/app.dart';
import 'package:beyond_peaks/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts on home with visible shell navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: BeyondPeaksApp()));
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('BeyondPeaks'), findsOneWidget);
    expect(find.text('3D 地球内容将在这里接入。'), findsOneWidget);
    expect(find.text('攀爬'), findsOneWidget);
    expect(find.text('收藏'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(scaffold.backgroundColor, AppColors.background);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.surface, AppColors.surface);
    expect(navBar.selectedIndex, 0);
  });

  testWidgets('tapping each tab switches to the matching placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: BeyondPeaksApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('攀爬'));
    await tester.pumpAndSettle();
    expect(find.text('攀爬功能占位。'), findsOneWidget);

    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();
    expect(find.text('收藏功能占位。'), findsOneWidget);

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('设置功能占位。'), findsOneWidget);

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 3);
  });
}
