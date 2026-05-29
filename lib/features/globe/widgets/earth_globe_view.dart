import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;

import '../../../shared/theme/app_colors.dart';
import '../../home/widgets/mountain_marker_overlay.dart';
import '../../mountain/models/mountain.dart';
import '../../mountain/utils/geo_to_globe_position.dart';
import '../controllers/globe_interaction_rules.dart';
import '../models/globe_marker_layout.dart';
import '../utils/globe_marker_hit_test.dart';

class EarthGlobeView extends StatefulWidget {
  const EarthGlobeView({
    super.key,
    required this.mountains,
    this.onMountainSelected,
    this.onBackgroundTap,
    this.assetBasePath = 'assets/models/',
    this.assetName = 'earth.glb',
  });

  static const earthModelFailureMessage = '地球模型加载失败';
  static const initializationFailureMessage = '3D 地球初始化失败';

  final List<Mountain> mountains;
  final ValueChanged<Mountain>? onMountainSelected;
  final VoidCallback? onBackgroundTap;
  final String assetBasePath;
  final String assetName;

  @visibleForTesting
  static Future<void> Function()? debugSceneSetupHook;

  @override
  State<EarthGlobeView> createState() => _EarthGlobeViewState();
}

class _EarthGlobeViewState extends State<EarthGlobeView> {
  static const _globeRadius = 1.0;
  static const _markerLift = 0.035;
  static const _dragThreshold = 8.0;

  late final three.ThreeJS _threeJs;
  three.PerspectiveCamera? _camera;
  three.OrbitControls? _controls;
  Size _viewportSize = Size.zero;
  Offset? _pointerStart;
  bool _didDrag = false;
  bool _isReady = false;
  String? _failureMessage;
  bool _autoRotateStopped = false;
  List<GlobeMarkerLayout> _markerLayouts = const [];

  @override
  void initState() {
    super.initState();
    _threeJs = three.ThreeJS(
      onSetupComplete: () {
        if (!mounted) {
          return;
        }
        if (_failureMessage != null) {
          return;
        }
        setState(() {
          _isReady = true;
          _markerLayouts = _projectMarkerLayouts();
        });
      },
      windowResizeUpdate: _handleWindowResize,
      setup: _setupScene,
    );
  }

  @override
  void dispose() {
    _controls?.dispose();
    _threeJs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final failureMessage = _failureMessage;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: failureMessage == null
                      ? Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (event) {
                            _pointerStart = event.localPosition;
                            _didDrag = false;
                          },
                          onPointerMove: (event) {
                            final pointerStart = _pointerStart;
                            if (pointerStart == null) {
                              return;
                            }
                            if ((event.localPosition - pointerStart)
                                    .distance >=
                                _dragThreshold) {
                              _didDrag = true;
                              _stopAutoRotate();
                            }
                          },
                          onPointerUp: (event) {
                            if (!_didDrag) {
                              _handleTap(event.localPosition);
                            }
                            _pointerStart = null;
                            _didDrag = false;
                          },
                          onPointerCancel: (_) {
                            _pointerStart = null;
                            _didDrag = false;
                          },
                          child: _threeJs.build(),
                        )
                      : const SizedBox.expand(),
                ),
                if (failureMessage != null)
                  Positioned.fill(
                    child: _GlobeFailureState(message: failureMessage),
                  )
                else if (!_isReady)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (failureMessage == null)
                  Positioned.fill(
                    child: MountainMarkerOverlay(markers: _markerLayouts),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleWindowResize(Size newSize) {
    _viewportSize = newSize;
    _syncCameraAspect();
  }

  void _syncCameraAspect() {
    final camera = _camera;
    if (camera == null ||
        _viewportSize.width <= 0 ||
        _viewportSize.height <= 0) {
      return;
    }

    camera.aspect = _viewportSize.width / _viewportSize.height;
    camera.updateProjectionMatrix();
  }

  Future<void> _setupScene() async {
    try {
      final debugSceneSetupHook = EarthGlobeView.debugSceneSetupHook;
      if (debugSceneSetupHook != null) {
        await debugSceneSetupHook();
        return;
      }

      final initialAspect = _threeJs.height > 0
          ? _threeJs.width / _threeJs.height
          : 1.0;

      _camera = three.PerspectiveCamera(
        45,
        initialAspect,
        0.1,
        100,
      );
      _camera!.position.setValues(
        0,
        0,
        GlobeInteractionRules.baseCameraDistance,
      );

      _threeJs.camera = _camera!;
      _threeJs.scene = three.Scene();
      _threeJs.scene.add(three.AmbientLight(0xffffff, 0.8));
      final keyLight = three.DirectionalLight(0xffffff, 1.4);
      keyLight.position.setValues(2.5, 2.0, 3.5);
      _threeJs.scene.add(keyLight);
      _threeJs.camera.lookAt(_threeJs.scene.position);

      final loader = three.GLTFLoader(
        flipY: true,
      ).setPath(widget.assetBasePath);
      final earth = await _loadEarthModel(loader);
      if (earth == null) {
        _showFailure(EarthGlobeView.earthModelFailureMessage);
        return;
      }
      _threeJs.scene.add(earth.scene);

      _replaceMountainMarkers();
      _controls = three.OrbitControls(_threeJs.camera, _threeJs.globalKey)
        ..enablePan = false
        ..enableRotate = true
        ..enableZoom = true
        ..enableDamping = true
        ..dampingFactor = 0.08
        ..minDistance = GlobeInteractionRules.minCameraDistance
        ..maxDistance = GlobeInteractionRules.maxCameraDistance
        ..autoRotate = GlobeInteractionRules.autoRotateOnEnter
        ..autoRotateSpeed = GlobeInteractionRules.autoRotateSpeed;

      _threeJs.addAnimationEvent((_) {
        if (_failureMessage != null) {
          return;
        }
        _controls?.update();
        final nextLayouts = _projectMarkerLayouts();
        if (!mounted) {
          return;
        }
        setState(() {
          _markerLayouts = nextLayouts;
        });
      });
    } catch (_) {
      _showFailure(EarthGlobeView.initializationFailureMessage);
    }
  }

  Future<three.GLTFData?> _loadEarthModel(three.GLTFLoader loader) async {
    try {
      return await loader.fromAsset(widget.assetName);
    } catch (_) {
      return null;
    }
  }

  void _replaceMountainMarkers() {
    final markerMaterial = three.MeshBasicMaterial.fromMap({
      'color': 0x324e58,
    });

    for (final mountain in widget.mountains) {
      final globePosition = geoToGlobePosition(
        latitude: mountain.latitude,
        longitude: mountain.longitude,
        radius: _globeRadius + _markerLift,
      );
      final marker = three.Mesh(
        three.SphereGeometry(0.025, 12, 8),
        markerMaterial,
      );
      marker.name = 'mountain-marker-${mountain.name}';
      marker.position.setValues(
        globePosition.x,
        globePosition.y,
        globePosition.z,
      );
      _threeJs.scene.add(marker);
    }
  }

  List<GlobeMarkerLayout> _projectMarkerLayouts() {
    final camera = _camera;
    if (camera == null || _viewportSize == Size.zero) {
      return const [];
    }

    _syncCameraAspect();
    camera.updateMatrixWorld(true);

    final cameraPosition = GlobePosition(
      camera.position.x,
      camera.position.y,
      camera.position.z,
    );

    return [
      for (final mountain in widget.mountains)
        _projectMountain(mountain, camera, cameraPosition),
    ];
  }

  GlobeMarkerLayout _projectMountain(
    Mountain mountain,
    three.Camera camera,
    GlobePosition cameraPosition,
  ) {
    final globePosition = geoToGlobePosition(
      latitude: mountain.latitude,
      longitude: mountain.longitude,
      radius: _globeRadius + _markerLift,
    );
    final visible = isFrontFacing(
      globePosition,
      cameraPosition: cameraPosition,
    );

    if (!visible) {
      return GlobeMarkerLayout(
        mountain: mountain,
        offset: Offset.zero,
        visible: false,
      );
    }

    final projected = three.Vector3(
      globePosition.x,
      globePosition.y,
      globePosition.z,
    ).project(camera);

    return GlobeMarkerLayout(
      mountain: mountain,
      offset: Offset(
        (projected.x + 1) * 0.5 * _viewportSize.width,
        (1 - projected.y) * 0.5 * _viewportSize.height,
      ),
      visible: projected.z >= -1 && projected.z <= 1,
    );
  }

  void _stopAutoRotate() {
    if (_autoRotateStopped) {
      return;
    }
    _autoRotateStopped = true;
    _controls?.autoRotate = false;
  }

  void _handleTap(Offset tapPosition) {
    if (_failureMessage != null || !_isReady) {
      return;
    }

    final tappedMountain = hitTestVisibleMountain(
      markers: _markerLayouts,
      tapPosition: tapPosition,
    );
    if (tappedMountain != null) {
      widget.onMountainSelected?.call(tappedMountain);
      return;
    }

    widget.onBackgroundTap?.call();
  }

  void _showFailure(String message) {
    if (!mounted) {
      return;
    }
    _controls?.dispose();
    _controls = null;
    setState(() {
      _failureMessage = message;
      _isReady = false;
      _markerLayouts = const [];
      _pointerStart = null;
      _didDrag = false;
    });
  }
}

class _GlobeFailureState extends StatelessWidget {
  const _GlobeFailureState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: AppColors.errorContainer,
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
