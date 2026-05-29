import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mountain/models/mountain.dart';

final selectedMountainProvider = StateProvider<Mountain?>((ref) => null);
