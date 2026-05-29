import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../providers/home_globe_view_provider.dart';
import '../providers/selected_mountain_provider.dart';
import '../widgets/mountain_detail_sheet.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMountain = ref.watch(selectedMountainProvider);
    final globeBuilder = ref.watch(homeGlobeViewProvider);

    return SafeArea(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '首页 3D 地球选山',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'BeyondPeaks',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: globeBuilder(
                    onMountainSelected: (mountain) {
                      ref.read(selectedMountainProvider.notifier).state =
                          mountain;
                    },
                    onBackgroundTap: () {
                      ref.read(selectedMountainProvider.notifier).state = null;
                    },
                  ),
                ),
              ],
            ),
            if (selectedMountain != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MountainDetailSheet(mountain: selectedMountain),
              ),
          ],
        ),
      ),
    );
  }
}
