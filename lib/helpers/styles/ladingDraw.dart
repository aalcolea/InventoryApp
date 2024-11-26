import 'package:flutter/material.dart';

import '../themes/colors.dart';

class LadingDraw extends StatelessWidget {
  const LadingDraw({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: AppColors3.primaryColor),//const BoxDecoration(color: Color(0xFFC5B6CD)),
      child: CustomPaint(
        painter: _LadingDraw(),
      ),
    );
  }
}

class _LadingDraw extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    final paintSubline = Paint();
    paintSubline.color = AppColors3.blackColor.withOpacity(0.5);
    paintSubline.style = PaintingStyle.stroke;
    paintSubline.strokeWidth = 10;
    paintSubline.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final pathSubline = Path();
    pathSubline.lineTo(0, size.height * 0.61);
    pathSubline.quadraticBezierTo(size.width * 0.25, size.height * 0.57,
        size.width * 0.5, size.height * 0.6);
    pathSubline.quadraticBezierTo(
        size.width * 0.75, size.height * 0.64, size.width, size.height * 0.595);
    pathSubline.lineTo(size.width, 0);
    canvas.drawPath(pathSubline, paintSubline);

    ///
    final paint = Paint();
    paint.color = AppColors3.whiteColor;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 1;

    final path = Path();
    path.lineTo(0, size.height * 0.61);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.57,
        size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.64, size.width, size.height * 0.595);
    path.lineTo(size.width, 0);
    canvas.drawPath(path, paint);

    ///
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
