import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../deviceThresholds.dart';

class DeviceInfo {
  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;
  late bool isTablet;

  DeviceInfo() {
    _initializeDeviceType();
  }

  void _initializeDeviceType() {
    final window = WidgetsBinding.instance.window;
    final devicePixelRatio = window.devicePixelRatio;
    final physicalSize = window.physicalSize;

    screenWidth = physicalSize.width / devicePixelRatio;
    screenHeight = physicalSize.height / devicePixelRatio;
    orientation = screenWidth > screenHeight ? Orientation.landscape : Orientation.portrait;
    isTablet = _isTabletDevice(screenWidth, screenHeight, orientation);
    _setAllowedOrientations();
  }

  void _setAllowedOrientations() {
    if (isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  bool _isTabletDevice(double width, double height, Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return height > DeviceThresholds.minTabletHeightPortrait &&
          width > DeviceThresholds.minTabletWidth;
    } else {
      return height > DeviceThresholds.minTabletHeightLandscape &&
          width > DeviceThresholds.minTabletWidthLandscape;
    }
  }
}
