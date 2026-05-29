import 'package:beyond_peaks/features/globe/models/globe_marker_layout.dart';
import 'package:beyond_peaks/features/globe/utils/globe_marker_hit_test.dart';
import 'package:beyond_peaks/features/mountain/models/mountain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hit test returns only visible mountains near the tap position', () {
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

    final markers = [
      GlobeMarkerLayout(
        mountain: hiddenMountain,
        offset: const Offset(40, 40),
        visible: false,
      ),
      GlobeMarkerLayout(
        mountain: visibleMountain,
        offset: const Offset(100, 100),
        visible: true,
      ),
    ];

    expect(
      hitTestVisibleMountain(
        markers: markers,
        tapPosition: const Offset(104, 96),
      ),
      visibleMountain,
    );
    expect(
      hitTestVisibleMountain(
        markers: markers,
        tapPosition: const Offset(40, 40),
      ),
      isNull,
    );
    expect(
      hitTestVisibleMountain(
        markers: markers,
        tapPosition: const Offset(220, 220),
      ),
      isNull,
    );
  });
}
