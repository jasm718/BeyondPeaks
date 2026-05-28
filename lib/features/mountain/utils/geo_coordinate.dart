void validateGeoCoordinate({
  required double latitude,
  required double longitude,
}) {
  if (latitude < -90 || latitude > 90) {
    throw RangeError.range(latitude, -90, 90, 'latitude');
  }
  if (longitude < -180 || longitude > 180) {
    throw RangeError.range(longitude, -180, 180, 'longitude');
  }
}
