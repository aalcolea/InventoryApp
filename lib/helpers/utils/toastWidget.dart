import 'package:flutter/material.dart';

class CustomToast extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;

  const CustomToast({
    Key? key,
    required this.message,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.duration = const Duration(seconds: 2200),
  }) : super(key: key);

  @override
  _CustomToastState createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          color: widget.backgroundColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.0),
          elevation: 4.0,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Text(
              textAlign: TextAlign.center,
              widget.message,
              style: TextStyle(
                  color: widget.textColor,
                  fontFamily: 'Poppins',
                  fontSize: MediaQuery.of(context).size.height * 0.027),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
