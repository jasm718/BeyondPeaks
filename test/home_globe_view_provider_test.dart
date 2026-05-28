import 'package:beyond_peaks/features/globe/widgets/earth_globe_view.dart';
import 'package:beyond_peaks/features/home/providers/home_globe_view_provider.dart';
import 'package:beyond_peaks/features/mountain/data/mountain_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home globe provider exposes the earth globe with fixed mountains', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final globeView = container.read(homeGlobeViewProvider);

    expect(globeView, isA<EarthGlobeView>());
    final earthGlobeView = globeView as EarthGlobeView;
    expect(earthGlobeView.mountains, MountainData.fixedMountains);
    expect(earthGlobeView.assetName, 'earth.glb');
  });
}
