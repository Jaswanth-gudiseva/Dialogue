import 'package:flutter/material.dart';

class SizeConfig {
  late MediaQueryData _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;

  late double _safeAreaHorizontal;
  late double _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;
  static num? bodyScreenHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    bodyScreenHeight =
        screenHeight! - _mediaQueryData.padding.top - kToolbarHeight;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight! - _safeAreaVertical) / 100;
  }
}
