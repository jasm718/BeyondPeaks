import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../globe/widgets/earth_globe_view.dart';
import '../../mountain/data/mountain_data.dart';

final homeGlobeViewProvider = Provider<Widget>((ref) {
  return EarthGlobeView(mountains: MountainData.fixedMountains);
});
