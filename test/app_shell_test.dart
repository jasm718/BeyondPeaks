import 'package:beyond_peaks/app/app.dart';
import 'package:beyond_peaks/features/home/providers/home_globe_view_provider.dart';
import 'package:beyond_peaks/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp() {
    return ProviderScope(
      overrides: [
        homeGlobeViewProvider.overrideWithValue(
          const SizedBox(key: ValueKey('home-globe-fake')),
        ),
      ],
      child: const BeyondPeaksApp(),
    );
  }

  testWidgets('app starts on home with visible shell navigation', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('BeyondPeaks'), findsOneWidget);
    expect(find.text('首页 3D 地球选山'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-globe-fake')), findsOneWidget);
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
    await tester.pumpWidget(buildApp());
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
