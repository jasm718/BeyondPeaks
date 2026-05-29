import 'package:beyond_peaks/app/app.dart';
import 'package:beyond_peaks/features/globe/widgets/earth_globe_view.dart';
import 'package:beyond_peaks/features/home/providers/home_globe_view_provider.dart';
import 'package:beyond_peaks/features/home/providers/home_mountains_provider.dart';
import 'package:beyond_peaks/features/mountain/data/mountain_data.dart';
import 'package:beyond_peaks/features/mountain/models/mountain.dart';
import 'package:beyond_peaks/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ValueChanged<Mountain> selectMountain;
  late VoidCallback tapBackground;

  HomeGlobeBuilder fakeGlobeBuilder({
    Widget globe = const SizedBox(key: ValueKey('home-globe-fake')),
  }) {
    return ({
      required ValueChanged<Mountain> onMountainSelected,
      required VoidCallback onBackgroundTap,
    }) {
      selectMountain = onMountainSelected;
      tapBackground = onBackgroundTap;
      return globe;
    };
  }

  Widget buildApp({HomeGlobeBuilder? globeBuilder, List overrides = const []}) {
    return ProviderScope(
      overrides: [
        ...overrides,
        homeGlobeViewProvider.overrideWithValue(
          globeBuilder ?? fakeGlobeBuilder(),
        ),
      ],
      child: const BeyondPeaksApp(),
    );
  }

  Future<void> pumpUntilText(WidgetTester tester, String text) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text(text).evaluate().isNotEmpty) {
        return;
      }
    }
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
    expect(find.byKey(const ValueKey('mountain-detail-sheet')), findsNothing);
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

  testWidgets('selecting a mountain opens and closes the detail sheet', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final mountain = MountainData.fixedMountains.first;
    selectMountain(mountain);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('mountain-detail-sheet')), findsOneWidget);
    expect(find.text(mountain.name), findsOneWidget);
    expect(
      find.text('${mountain.region} · ${mountain.elevationMeters}m'),
      findsOneWidget,
    );
    expect(find.text(mountain.defaultRouteName), findsOneWidget);
    expect(find.text(mountain.routeSummary), findsOneWidget);

    tapBackground();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('mountain-detail-sheet')), findsNothing);
  });

  testWidgets('selected mountain returns when navigating back to home', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final mountain = MountainData.fixedMountains[1];
    selectMountain(mountain);
    await tester.pumpAndSettle();
    expect(find.text(mountain.name), findsOneWidget);

    await tester.tap(find.text('攀爬'));
    await tester.pumpAndSettle();
    expect(find.text('攀爬功能占位。'), findsOneWidget);
    expect(find.text(mountain.name), findsNothing);

    await tester.tap(find.text('首页'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('mountain-detail-sheet')), findsOneWidget);
    expect(find.text(mountain.name), findsOneWidget);
  });

  testWidgets('home shows an empty state when mountain data is empty', (
    tester,
  ) async {
    var globeBuilt = false;

    await tester.pumpWidget(
      buildApp(
        globeBuilder:
            ({
              required ValueChanged<Mountain> onMountainSelected,
              required VoidCallback onBackgroundTap,
            }) {
              globeBuilt = true;
              return const SizedBox(key: ValueKey('home-globe-fake'));
            },
        overrides: [
          homeMountainsProvider.overrideWithValue(const <Mountain>[]),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无可展示山峰'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-globe-empty-state')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-globe-fake')), findsNothing);
    expect(globeBuilt, isFalse);
  });

  testWidgets('earth model failure keeps shell navigation usable', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        globeBuilder:
            ({
              required ValueChanged<Mountain> onMountainSelected,
              required VoidCallback onBackgroundTap,
            }) {
              return EarthGlobeView(
                mountains: MountainData.fixedMountains,
                onMountainSelected: onMountainSelected,
                onBackgroundTap: onBackgroundTap,
                assetName: 'missing-earth.glb',
              );
            },
      ),
    );
    await pumpUntilText(tester, '地球模型加载失败');

    expect(find.text('地球模型加载失败'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('攀爬'));
    await pumpUntilText(tester, '攀爬功能占位。');

    expect(find.text('攀爬功能占位。'), findsOneWidget);
  });

  testWidgets('globe failure does not enter interaction state', (tester) async {
    var selected = false;
    var backgroundTapped = false;

    await tester.pumpWidget(
      buildApp(
        globeBuilder:
            ({
              required ValueChanged<Mountain> onMountainSelected,
              required VoidCallback onBackgroundTap,
            }) {
              return EarthGlobeView(
                mountains: MountainData.fixedMountains,
                onMountainSelected: (_) {
                  selected = true;
                },
                onBackgroundTap: () {
                  backgroundTapped = true;
                },
                assetName: 'missing-earth.glb',
              );
            },
      ),
    );
    await pumpUntilText(tester, '地球模型加载失败');

    expect(find.text('地球模型加载失败'), findsOneWidget);

    await tester.tap(find.text('地球模型加载失败'));
    await tester.pump();

    expect(selected, isFalse);
    expect(backgroundTapped, isFalse);
  });

  testWidgets('3D initialization failure does not enter interaction state', (
    tester,
  ) async {
    addTearDown(() {
      EarthGlobeView.debugSceneSetupHook = null;
    });
    EarthGlobeView.debugSceneSetupHook = () async {
      throw StateError('setup failed');
    };

    var selected = false;
    var backgroundTapped = false;

    await tester.pumpWidget(
      buildApp(
        globeBuilder:
            ({
              required ValueChanged<Mountain> onMountainSelected,
              required VoidCallback onBackgroundTap,
            }) {
              return EarthGlobeView(
                mountains: MountainData.fixedMountains,
                onMountainSelected: (_) {
                  selected = true;
                },
                onBackgroundTap: () {
                  backgroundTapped = true;
                },
              );
            },
      ),
    );
    await pumpUntilText(tester, '3D 地球初始化失败');

    expect(find.text('3D 地球初始化失败'), findsOneWidget);

    await tester.tap(find.text('3D 地球初始化失败'));
    await tester.pump();

    expect(selected, isFalse);
    expect(backgroundTapped, isFalse);
  });
}
