import 'package:beyond_peaks/features/globe/widgets/earth_globe_view.dart';
import 'package:beyond_peaks/features/home/providers/home_globe_view_provider.dart';
import 'package:beyond_peaks/features/home/providers/home_mountains_provider.dart';
import 'package:beyond_peaks/features/mountain/data/mountain_data.dart';
import 'package:beyond_peaks/features/mountain/models/mountain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home globe provider exposes the earth globe with fixed mountains', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final globeView = container.read(homeGlobeViewProvider)(
      onMountainSelected: (_) {},
      onBackgroundTap: () {},
    );

    expect(globeView, isA<EarthGlobeView>());
    final earthGlobeView = globeView as EarthGlobeView;
    expect(earthGlobeView.mountains, MountainData.fixedMountains);
    expect(earthGlobeView.assetName, 'earth.glb');
  });

  test('home globe provider uses the current home mountain data source', () {
    final mountain = Mountain(
      name: '测试山',
      region: '测试',
      elevationMeters: 1000,
      latitude: 1,
      longitude: 2,
      defaultRouteName: '测试路线',
      routeSummary: '测试摘要',
    );
    final container = ProviderContainer(
      overrides: [
        homeMountainsProvider.overrideWithValue([mountain]),
      ],
    );
    addTearDown(container.dispose);

    final globeView = container.read(homeGlobeViewProvider)(
      onMountainSelected: (_) {},
      onBackgroundTap: () {},
    );

    expect((globeView as EarthGlobeView).mountains, [mountain]);
  });

  test('invalid home mountain data is rejected before rendering', () {
    expect(
      () => Mountain(
        name: '错误山峰',
        region: '测试',
        elevationMeters: 1000,
        latitude: 0,
        longitude: 181,
        defaultRouteName: '测试路线',
        routeSummary: '测试摘要',
      ),
      throwsRangeError,
    );
  });
}
