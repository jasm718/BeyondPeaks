import 'package:beyond_peaks/features/globe/controllers/globe_interaction_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stage-one interaction rules expose the required zoom range', () {
    expect(GlobeInteractionRules.minZoomScale, 0.8);
    expect(GlobeInteractionRules.maxZoomScale, 2.0);
    expect(
      GlobeInteractionRules.minCameraDistance,
      closeTo(
        GlobeInteractionRules.baseCameraDistance /
            GlobeInteractionRules.maxZoomScale,
        1e-9,
      ),
    );
    expect(
      GlobeInteractionRules.maxCameraDistance,
      closeTo(
        GlobeInteractionRules.baseCameraDistance /
            GlobeInteractionRules.minZoomScale,
        1e-9,
      ),
    );
  });

  test('stage-one globe starts with auto rotation enabled', () {
    expect(GlobeInteractionRules.autoRotateOnEnter, isTrue);
    expect(GlobeInteractionRules.autoRotateSpeed, greaterThan(0));
  });
}
