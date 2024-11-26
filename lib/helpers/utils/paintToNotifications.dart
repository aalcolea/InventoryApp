import 'package:flutter/material.dart';

import '../themes/colors.dart';

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors2.BgprimaryColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors2.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final whiteBorderPaint = Paint()
      ..color = AppColors2.BgprimaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.3;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);

    canvas.drawPath(path, borderPaint);

    final bottomBorderPath = Path()
      ..moveTo(-3, size.height) //
      ..lineTo(size.width + 3, size.height);
    canvas.drawPath(bottomBorderPath, whiteBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
