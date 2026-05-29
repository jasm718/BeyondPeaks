import 'package:flutter/widgets.dart';

import '../../mountain/models/mountain.dart';
import '../models/globe_marker_layout.dart';

Mountain? hitTestVisibleMountain({
  required List<GlobeMarkerLayout> markers,
  required Offset tapPosition,
  double hitRadius = 72,
}) {
  for (final marker in markers) {
    if (!marker.visible) {
      continue;
    }
    if ((marker.offset - tapPosition).distance <= hitRadius) {
      return marker.mountain;
    }
  }
  return null;
}
