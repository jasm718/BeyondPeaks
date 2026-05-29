void validateGeoCoordinate({
  required double latitude,
  required double longitude,
}) {
  if (!latitude.isFinite) {
    throw ArgumentError.value(latitude, 'latitude', 'Latitude must be finite.');
  }
  if (!longitude.isFinite) {
    throw ArgumentError.value(
      longitude,
      'longitude',
      'Longitude must be finite.',
    );
  }
  if (latitude < -90 || latitude > 90) {
    throw RangeError.range(latitude, -90, 90, 'latitude');
  }
  if (longitude < -180 || longitude > 180) {
    throw RangeError.range(longitude, -180, 180, 'longitude');
  }
}
