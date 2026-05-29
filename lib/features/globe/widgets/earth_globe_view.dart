import 'package:flutter/material.dart';
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
    this.textureBasePath = 'assets/textures/planets/',
    this.dayTextureName = 'earth_day_4096.jpg',
    this.nightTextureName = 'earth_night_4096.jpg',
    this.bumpRoughnessCloudsTextureName =
        'earth_bump_roughness_clouds_4096.jpg',
  });

  static const earthTextureFailureMessage = '地球贴图加载失败';
  static const initializationFailureMessage = '3D 地球初始化失败';

  final List<Mountain> mountains;
  final ValueChanged<Mountain>? onMountainSelected;
  final VoidCallback? onBackgroundTap;
  final String textureBasePath;
  final String dayTextureName;
  final String nightTextureName;
  final String bumpRoughnessCloudsTextureName;

  @visibleForTesting
  static Future<void> Function()? debugSceneSetupHook;

  @override
  State<EarthGlobeView> createState() => _EarthGlobeViewState();
}

class _EarthGlobeViewState extends State<EarthGlobeView> {
  static const _globeRadius = 1.0;
  static const _markerLift = 0.035;
  static const _dragThreshold = 8.0;

  three.ThreeJS? _threeJs;
  three.PerspectiveCamera? _camera;
  three.OrbitControls? _controls;
  three.Mesh? _globe;
  _EarthTextures? _earthTextures;
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
    _prepareGlobe();
  }

  @override
  void dispose() {
    _controls?.dispose();
    if (_threeJs?.mounted == true) {
      _threeJs!.dispose();
    }
    _earthTextures?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        final failureMessage = _failureMessage;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: failureMessage == null
                      ? _threeJs == null
                            ? const SizedBox.expand()
                            : Listener(
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
                                child: _threeJs!.build(),
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
      final threeJs = _threeJs;
      final textures = _earthTextures;
      if (threeJs == null || textures == null) {
        return;
      }

      final initialAspect = threeJs.height > 0
          ? threeJs.width / threeJs.height
          : 1.0;

      _camera = three.PerspectiveCamera(25, initialAspect, 0.1, 100);
      _camera!.position.setValues(4.5, 2.0, 3.0);

      threeJs.camera = _camera!;
      threeJs.scene = three.Scene();
      threeJs.scene.background = three.Color.fromHex32(0x000000);
      threeJs.camera.lookAt(threeJs.scene.position);

      final sphereGeometry = three.SphereGeometry(_globeRadius, 64, 64);
      final globe = three.Mesh(sphereGeometry, _createGlobeMaterial(textures));
      _globe = globe;
      threeJs.scene.add(globe);

      final atmosphere = three.Mesh(
        three.SphereGeometry(_globeRadius, 64, 64),
        _createAtmosphereMaterial(),
      );
      atmosphere.scale.setScalar(1.04);
      threeJs.scene.add(atmosphere);

      _controls = three.OrbitControls(threeJs.camera, threeJs.globalKey)
        ..enablePan = false
        ..enableRotate = true
        ..enableZoom = true
        ..enableDamping = true
        ..dampingFactor = 0.08
        ..minDistance = GlobeInteractionRules.minCameraDistance
        ..maxDistance = GlobeInteractionRules.maxCameraDistance
        ..autoRotate = false;

      threeJs.addAnimationEvent((dt) {
        if (_failureMessage != null) {
          return;
        }
        if (!_autoRotateStopped && GlobeInteractionRules.autoRotateOnEnter) {
          _globe?.rotation.y += dt * GlobeInteractionRules.autoRotateSpeed;
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

  Future<void> _prepareGlobe() async {
    try {
      final debugSceneSetupHook = EarthGlobeView.debugSceneSetupHook;
      if (debugSceneSetupHook != null) {
        await debugSceneSetupHook();
      }
    } catch (_) {
      _showFailure(EarthGlobeView.initializationFailureMessage);
      return;
    }

    try {
      _earthTextures = await _loadEarthTextures();
    } catch (_) {
      _showFailure(EarthGlobeView.earthTextureFailureMessage);
      return;
    }

    if (!mounted) {
      _earthTextures?.dispose();
      _earthTextures = null;
      return;
    }

    setState(() {
      _threeJs = three.ThreeJS(
        settings: three.Settings(antialias: true, clearColor: 0x000000),
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
    });
  }

  Future<_EarthTextures> _loadEarthTextures() async {
    final loader = three.TextureLoader().setPath(widget.textureBasePath);
    final dayTexture = await loader.fromAsset(widget.dayTextureName);
    final nightTexture = await loader.fromAsset(widget.nightTextureName);
    final bumpRoughnessCloudsTexture = await loader.fromAsset(
      widget.bumpRoughnessCloudsTextureName,
    );

    if (dayTexture == null ||
        nightTexture == null ||
        bumpRoughnessCloudsTexture == null) {
      throw StateError('Earth textures failed to load.');
    }

    dayTexture
      ..colorSpace = three.SRGBColorSpace
      ..anisotropy = 8;
    nightTexture
      ..colorSpace = three.SRGBColorSpace
      ..anisotropy = 8;
    bumpRoughnessCloudsTexture
      ..colorSpace = three.NoColorSpace
      ..anisotropy = 8;

    return _EarthTextures(
      day: dayTexture,
      night: nightTexture,
      bumpRoughnessClouds: bumpRoughnessCloudsTexture,
    );
  }

  three.ShaderMaterial _createGlobeMaterial(_EarthTextures textures) {
    return three.ShaderMaterial.fromMap({
      'uniforms': {
        'dayTexture': {'value': textures.day},
        'nightTexture': {'value': textures.night},
        'bumpRoughnessCloudsTexture': {'value': textures.bumpRoughnessClouds},
        'sunDirection': {'value': three.Vector3(0, 0, 1)},
        'atmosphereDayColor': {'value': three.Color.fromHex32(0x4db2ff)},
        'atmosphereTwilightColor': {'value': three.Color.fromHex32(0xbc490b)},
      },
      'vertexShader': _globeVertexShader,
      'fragmentShader': _globeFragmentShader,
    });
  }

  three.ShaderMaterial _createAtmosphereMaterial() {
    return three.ShaderMaterial.fromMap({
      'uniforms': {
        'sunDirection': {'value': three.Vector3(0, 0, 1)},
        'atmosphereDayColor': {'value': three.Color.fromHex32(0x4db2ff)},
        'atmosphereTwilightColor': {'value': three.Color.fromHex32(0xbc490b)},
      },
      'vertexShader': _atmosphereVertexShader,
      'fragmentShader': _atmosphereFragmentShader,
      'transparent': true,
      'side': three.BackSide,
      'depthWrite': false,
    });
  }

  List<GlobeMarkerLayout> _projectMarkerLayouts() {
    final camera = _camera;
    if (camera == null || _viewportSize == Size.zero) {
      return const [];
    }

    _syncCameraAspect();
    camera.updateMatrixWorld(true);
    _globe?.updateMatrixWorld(true);

    final cameraWorldPosition = three.Vector3().setFromMatrixPosition(
      camera.matrixWorld,
    );
    final cameraPosition = GlobePosition(
      cameraWorldPosition.x,
      cameraWorldPosition.y,
      cameraWorldPosition.z,
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
    final localPosition = geoToGlobePosition(
      latitude: mountain.latitude,
      longitude: mountain.longitude,
      radius: _globeRadius + _markerLift,
    );
    final worldPosition = _globe?.localToWorld(
      three.Vector3(localPosition.x, localPosition.y, localPosition.z),
    );
    if (worldPosition == null) {
      return GlobeMarkerLayout(
        mountain: mountain,
        offset: Offset.zero,
        visible: false,
      );
    }

    final globePosition = GlobePosition(
      worldPosition.x,
      worldPosition.y,
      worldPosition.z,
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

    final projected = worldPosition.project(camera);

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

class _EarthTextures {
  const _EarthTextures({
    required this.day,
    required this.night,
    required this.bumpRoughnessClouds,
  });

  final three.Texture day;
  final three.Texture night;
  final three.Texture bumpRoughnessClouds;

  void dispose() {
    day.dispose();
    night.dispose();
    bumpRoughnessClouds.dispose();
  }
}

const _globeVertexShader = '''
varying vec2 vUv;
varying vec3 vNormalWorld;
varying vec3 vWorldPosition;

void main() {
  vUv = uv;
  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  vWorldPosition = worldPosition.xyz;
  vNormalWorld = normalize(mat3(modelMatrix) * normal);
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
''';

const _globeFragmentShader = '''
uniform sampler2D dayTexture;
uniform sampler2D nightTexture;
uniform sampler2D bumpRoughnessCloudsTexture;
uniform vec3 sunDirection;
uniform vec3 atmosphereDayColor;
uniform vec3 atmosphereTwilightColor;

varying vec2 vUv;
varying vec3 vNormalWorld;
varying vec3 vWorldPosition;

void main() {
  vec3 normalWorld = normalize(vNormalWorld);
  float sunOrientation = dot(normalWorld, normalize(sunDirection));

  vec3 dayColor = texture2D(dayTexture, vUv).rgb;
  vec3 nightColor = texture2D(nightTexture, vUv).rgb;
  vec3 bumpRoughnessClouds = texture2D(bumpRoughnessCloudsTexture, vUv).rgb;

  float cloudsStrength = smoothstep(0.2, 1.0, bumpRoughnessClouds.b);
  vec3 sunlitColor = mix(dayColor, vec3(1.0), clamp(cloudsStrength * 2.0, 0.0, 1.0));
  float dayStrength = smoothstep(-0.25, 0.5, sunOrientation);

  vec3 viewDirection = normalize(vWorldPosition - cameraPosition);
  float fresnel = 1.0 - abs(dot(viewDirection, normalWorld));
  vec3 atmosphereColor = mix(
    atmosphereTwilightColor,
    atmosphereDayColor,
    smoothstep(-0.25, 0.75, sunOrientation)
  );
  float atmosphereMix = clamp(
    smoothstep(-0.5, 1.0, sunOrientation) * pow(fresnel, 2.0),
    0.0,
    1.0
  );

  vec3 finalColor = mix(nightColor, sunlitColor, dayStrength);
  finalColor = mix(finalColor, atmosphereColor, atmosphereMix);

  gl_FragColor = vec4(finalColor, 1.0);
}
''';

const _atmosphereVertexShader = '''
varying vec3 vNormalWorld;
varying vec3 vWorldPosition;

void main() {
  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  vWorldPosition = worldPosition.xyz;
  vNormalWorld = normalize(mat3(modelMatrix) * normal);
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
''';

const _atmosphereFragmentShader = '''
uniform vec3 sunDirection;
uniform vec3 atmosphereDayColor;
uniform vec3 atmosphereTwilightColor;

varying vec3 vNormalWorld;
varying vec3 vWorldPosition;

void main() {
  vec3 normalWorld = normalize(vNormalWorld);
  float sunOrientation = dot(normalWorld, normalize(sunDirection));
  vec3 viewDirection = normalize(vWorldPosition - cameraPosition);
  float fresnel = 1.0 - abs(dot(viewDirection, normalWorld));

  vec3 atmosphereColor = mix(
    atmosphereTwilightColor,
    atmosphereDayColor,
    smoothstep(-0.25, 0.75, sunOrientation)
  );
  float alpha = pow(fresnel, 3.0) * smoothstep(-0.5, 1.0, sunOrientation) * 0.85;

  gl_FragColor = vec4(atmosphereColor, alpha);
}
''';

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
