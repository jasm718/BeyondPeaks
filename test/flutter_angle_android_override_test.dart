import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('local flutter_angle Android override keeps emulators off ANGLE', () {
    final pluginFile = File(
      'third_party/flutter_angle/android/src/main/java/org/fluttergl/flutter_angle/FlutterAnglePlugin.java',
    );

    final source = pluginFile.readAsStringSync();

    expect(source, contains('public static boolean isEmulator()'));
    expect(
      source,
      contains('if (isEmulator() || !isVersionAllowed() || isBlacklistedForAngle())'),
    );
  });
}
