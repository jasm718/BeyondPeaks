import 'package:beyond_peaks/features/globe/models/globe_marker_layout.dart';
import 'package:beyond_peaks/features/home/widgets/mountain_marker_overlay.dart';
import 'package:beyond_peaks/features/mountain/models/mountain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('overlay renders visible mountain labels and hides back-side ones', (
    tester,
  ) async {
    final visibleMountain = Mountain(
      name: '可见山',
      region: '测试',
      elevationMeters: 1000,
      latitude: 0,
      longitude: 0,
      defaultRouteName: '测试路线',
      routeSummary: '测试摘要',
    );
    final hiddenMountain = Mountain(
      name: '隐藏山',
      region: '测试',
      elevationMeters: 2000,
      latitude: 0,
      longitude: 180,
      defaultRouteName: '测试路线',
      routeSummary: '测试摘要',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 240,
          height: 240,
          child: MountainMarkerOverlay(
            markers: [
              GlobeMarkerLayout(
                mountain: visibleMountain,
                offset: const Offset(120, 120),
                visible: true,
              ),
              GlobeMarkerLayout(
                mountain: hiddenMountain,
                offset: const Offset(20, 20),
                visible: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('可见山'), findsOneWidget);
    expect(find.text('1000m'), findsOneWidget);
    expect(find.text('隐藏山'), findsNothing);
    expect(find.text('2000m'), findsNothing);

    final label = tester.widget<SizedBox>(
      find.byKey(const ValueKey('mountain-marker-label-可见山')),
    );
    expect(label.width, MountainMarkerOverlay.labelWidth);
  });
}
