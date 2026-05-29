import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mountain/data/mountain_data.dart';
import '../../mountain/models/mountain.dart';

final homeMountainsProvider = Provider<List<Mountain>>((ref) {
  return MountainData.fixedMountains;
});
