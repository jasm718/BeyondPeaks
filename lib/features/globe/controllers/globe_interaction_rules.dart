class GlobeInteractionRules {
  const GlobeInteractionRules._();

  static const minZoomScale = 0.8;
  static const maxZoomScale = 2.0;
  static const baseCameraDistance = 3.2;
  static const minCameraDistance = baseCameraDistance / maxZoomScale;
  static const maxCameraDistance = baseCameraDistance / minZoomScale;
  static const autoRotateOnEnter = true;
  static const autoRotateSpeed = 0.35;
}
