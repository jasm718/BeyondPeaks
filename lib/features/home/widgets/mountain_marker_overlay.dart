import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../globe/models/globe_marker_layout.dart';

class MountainMarkerOverlay extends StatelessWidget {
  const MountainMarkerOverlay({super.key, required this.markers});

  static const labelWidth = 112.0;
  static const markerSize = 9.0;

  final List<GlobeMarkerLayout> markers;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (final marker in markers)
            if (marker.visible)
              Positioned(
                left: marker.offset.dx - labelWidth / 2,
                top: marker.offset.dy - 42,
                child: _MountainMarkerLabel(marker: marker),
              ),
        ],
      ),
    );
  }
}

class _MountainMarkerLabel extends StatelessWidget {
  const _MountainMarkerLabel({required this.marker});

  final GlobeMarkerLayout marker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      key: ValueKey('mountain-marker-label-${marker.mountain.name}'),
      width: MountainMarkerOverlay.labelWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MountainMarkerOverlay.markerSize,
            height: MountainMarkerOverlay.markerSize,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withOpacity(0.92),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    marker.mountain.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${marker.mountain.elevationMeters}m',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
