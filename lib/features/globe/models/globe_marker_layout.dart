import 'package:flutter/widgets.dart';

import '../../mountain/models/mountain.dart';

class GlobeMarkerLayout {
  const GlobeMarkerLayout({
    required this.mountain,
    required this.offset,
    required this.visible,
  });

  final Mountain mountain;
  final Offset offset;
  final bool visible;
}
