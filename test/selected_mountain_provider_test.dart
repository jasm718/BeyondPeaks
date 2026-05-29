import 'package:beyond_peaks/features/home/providers/selected_mountain_provider.dart';
import 'package:beyond_peaks/features/mountain/data/mountain_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selected mountain starts empty and can be set and cleared', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedMountainProvider), isNull);

    final mountain = MountainData.fixedMountains.first;
    container.read(selectedMountainProvider.notifier).state = mountain;
    expect(container.read(selectedMountainProvider), mountain);

    container.read(selectedMountainProvider.notifier).state = null;
    expect(container.read(selectedMountainProvider), isNull);
  });
}
