import 'package:flutter/material.dart';

void showOverlay(BuildContext context, Widget widget) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.85,
      width: MediaQuery.of(context).size.width,
      child: Material(
        color: Colors.transparent,
        child: widget,
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(const Duration(milliseconds: 2200), () {
    overlayEntry.remove();
  });
}
