import '../utils/geo_coordinate.dart';

class Mountain {
  factory Mountain({
    required String name,
    required String region,
    required int elevationMeters,
    required double latitude,
    required double longitude,
    required String defaultRouteName,
    required String routeSummary,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Mountain name must not be empty.');
    }
    if (region.trim().isEmpty) {
      throw ArgumentError.value(
        region,
        'region',
        'Mountain region must not be empty.',
      );
    }
    if (elevationMeters <= 0) {
      throw RangeError.range(elevationMeters, 1, null, 'elevationMeters');
    }
    if (defaultRouteName.trim().isEmpty) {
      throw ArgumentError.value(
        defaultRouteName,
        'defaultRouteName',
        'Default route name must not be empty.',
      );
    }
    if (routeSummary.trim().isEmpty) {
      throw ArgumentError.value(
        routeSummary,
        'routeSummary',
        'Route summary must not be empty.',
      );
    }

    validateGeoCoordinate(latitude: latitude, longitude: longitude);

    return Mountain._(
      name: name,
      region: region,
      elevationMeters: elevationMeters,
      latitude: latitude,
      longitude: longitude,
      defaultRouteName: defaultRouteName,
      routeSummary: routeSummary,
    );
  }

  const Mountain._({
    required this.name,
    required this.region,
    required this.elevationMeters,
    required this.latitude,
    required this.longitude,
    required this.defaultRouteName,
    required this.routeSummary,
  });

  final String name;
  final String region;
  final int elevationMeters;
  final double latitude;
  final double longitude;
  final String defaultRouteName;
  final String routeSummary;
}
