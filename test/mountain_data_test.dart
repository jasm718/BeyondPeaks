import 'package:beyond_peaks/features/mountain/data/mountain_data.dart';
import 'package:beyond_peaks/features/mountain/models/mountain.dart';
import 'package:beyond_peaks/features/mountain/utils/geo_to_globe_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fixed data exposes the three stage-one mountains', () {
    final mountains = MountainData.fixedMountains;

    expect(mountains, hasLength(3));
    expect(
      mountains.map((mountain) => mountain.name),
      ['珠穆朗玛峰', '乔戈里峰', '马特洪峰'],
    );
    expect(
      mountains.map((mountain) => mountain.elevationMeters),
      [8848, 8611, 4478],
    );
    expect(
      mountains.every(
        (mountain) =>
            mountain.region.isNotEmpty &&
            mountain.defaultRouteName.isNotEmpty &&
            mountain.routeSummary.isNotEmpty,
      ),
      isTrue,
    );
  });

  test('geo coordinates map to the expected globe positions', () {
    final front = geoToGlobePosition(latitude: 0, longitude: 0);
    final northPole = geoToGlobePosition(latitude: 90, longitude: 0);
    final east = geoToGlobePosition(latitude: 0, longitude: 90, radius: 2);

    expect(front.x, closeTo(0, 1e-9));
    expect(front.y, closeTo(0, 1e-9));
    expect(front.z, closeTo(1, 1e-9));
    expect(northPole.y, closeTo(1, 1e-9));
    expect(east.x, closeTo(2, 1e-9));
    expect(east.y, closeTo(0, 1e-9));
    expect(east.z, closeTo(0, 1e-9));
    expect(isFrontFacing(front, cameraPosition: const GlobePosition(0, 0, 3)), isTrue);
    expect(
      isFrontFacing(
        geoToGlobePosition(latitude: 0, longitude: 180),
        cameraPosition: const GlobePosition(0, 0, 3),
      ),
      isFalse,
    );
  });

  test('invalid mountain coordinates fail fast', () {
    expect(
      () => geoToGlobePosition(latitude: 91, longitude: 0),
      throwsRangeError,
    );
    expect(
      () => geoToGlobePosition(latitude: 0, longitude: -181),
      throwsRangeError,
    );
    expect(
      () => Mountain(
        name: '错误山峰',
        region: '测试',
        elevationMeters: 1,
        latitude: -91,
        longitude: 0,
        defaultRouteName: '测试路线',
        routeSummary: '测试路线摘要',
      ),
      throwsRangeError,
    );
    expect(
      () => geoToGlobePosition(latitude: double.nan, longitude: 0),
      throwsArgumentError,
    );
    expect(
      () => geoToGlobePosition(latitude: 0, longitude: double.infinity),
      throwsArgumentError,
    );
  });
}
