import 'dart:math' as math;

import 'geo_coordinate.dart';

class GlobePosition {
  const GlobePosition(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  double dot(GlobePosition other) {
    return x * other.x + y * other.y + z * other.z;
  }
}

GlobePosition geoToGlobePosition({
  required double latitude,
  required double longitude,
  double radius = 1,
}) {
  if (radius <= 0) {
    throw RangeError.range(radius, 0, null, 'radius');
  }

  validateGeoCoordinate(latitude: latitude, longitude: longitude);

  final latitudeRadians = latitude * math.pi / 180;
  final longitudeRadians = longitude * math.pi / 180;
  final latitudeCosine = math.cos(latitudeRadians);

  return GlobePosition(
    radius * latitudeCosine * math.sin(longitudeRadians),
    radius * math.sin(latitudeRadians),
    radius * latitudeCosine * math.cos(longitudeRadians),
  );
}

bool isFrontFacing(
  GlobePosition position, {
  required GlobePosition cameraPosition,
}) {
  return position.dot(cameraPosition) > 0;
}
