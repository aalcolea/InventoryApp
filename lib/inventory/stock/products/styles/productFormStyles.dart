import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../themes/colors.dart';

class TitleContainer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry alignment;
  final BoxDecoration decoration;
  final Widget? child;

  const TitleContainer({
    super.key,
    this.padding,
    this.margin,
    this.alignment = Alignment.centerLeft,
    this.decoration = const BoxDecoration(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry defaultPadding = EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.width * 0.02,
      horizontal: MediaQuery.of(context).size.width * 0.02,
    );

    final EdgeInsetsGeometry defaultMargin = EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.025,
    );

    return Container(
      padding: padding ?? defaultPadding,
      margin: margin ?? defaultMargin,
      alignment: alignment,
      decoration: decoration,
      child: child,
    );
  }
}

class TitleModContainer extends StatelessWidget {
  final String text;
  final double? width;
  final Alignment? aligment;
  final EdgeInsetsGeometry? padding;

  TitleModContainer({required this.text, this.width, this.aligment, this.padding});

  @override
  Widget build(BuildContext context) {

    final defaultWidth = MediaQuery.of(context).size.width;
    const defaultAlingment = Alignment.centerLeft;
    final EdgeInsetsGeometry defaultPadding =  EdgeInsets.only(
      left: MediaQuery.of(context).size.width * 0.02,
    );


    return Container(
      alignment: aligment ?? defaultAlingment,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.width * 0.04,
        left: MediaQuery.of(context).size.width * 0.03,
        right: MediaQuery.of(context).size.width * 0.03,
      ),
      height: MediaQuery.of(context).size.width * 0.09,
      padding: padding ?? defaultPadding,
      width: width ?? defaultWidth,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

//String? Function(String?)? validator,

class TextProdField extends StatelessWidget {
  final bool enabled;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final VoidCallback? onEditingComplete;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String? text;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? label;
  final TextStyle? textStyle;

  const TextProdField({
    super.key,
    this.enabled = true,
    this.focusNode,
    this.controller,
    this.onEditingComplete,
    this.onChanged, this.text, this.inputFormatters, this.keyboardType, this.label, this.textStyle, this.validator,
  });

  @override
  Widget build(BuildContext context) {

    final defaultStyleLetterColor = TextStyle(
        color: AppColors.primaryColor.withOpacity(0.5),
    );

    return TextFormField(
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      focusNode: focusNode,
      controller: controller,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.03,
        ),

        label: Text(
          text!,
          style: textStyle ?? defaultStyleLetterColor,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),

        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        errorStyle: const TextStyle(
          color: Colors.red, // Personalizar el estilo del mensaje de error si es necesario
          fontSize: 12,
        ),
      ),
    );
  }
}

