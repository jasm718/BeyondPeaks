import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../globe/widgets/earth_globe_view.dart';
import '../../mountain/data/mountain_data.dart';
import '../../mountain/models/mountain.dart';

typedef HomeGlobeBuilder = Widget Function({
  required ValueChanged<Mountain> onMountainSelected,
  required VoidCallback onBackgroundTap,
});

final homeGlobeViewProvider = Provider<HomeGlobeBuilder>((ref) {
  return ({
    required ValueChanged<Mountain> onMountainSelected,
    required VoidCallback onBackgroundTap,
  }) {
    return EarthGlobeView(
      mountains: MountainData.fixedMountains,
      onMountainSelected: onMountainSelected,
      onBackgroundTap: onBackgroundTap,
    );
  };
});
