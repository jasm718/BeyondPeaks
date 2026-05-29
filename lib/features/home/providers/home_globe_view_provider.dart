import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../globe/widgets/earth_globe_view.dart';
import '../../mountain/models/mountain.dart';
import 'home_mountains_provider.dart';

typedef HomeGlobeBuilder =
    Widget Function({
      required ValueChanged<Mountain> onMountainSelected,
      required VoidCallback onBackgroundTap,
    });

final homeGlobeViewProvider = Provider<HomeGlobeBuilder>((ref) {
  final mountains = ref.watch(homeMountainsProvider);

  return ({
    required ValueChanged<Mountain> onMountainSelected,
    required VoidCallback onBackgroundTap,
  }) {
    return EarthGlobeView(
      mountains: mountains,
      onMountainSelected: onMountainSelected,
      onBackgroundTap: onBackgroundTap,
    );
  };
});
