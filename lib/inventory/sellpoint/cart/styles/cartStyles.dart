import 'package:flutter/material.dart';
import '../../../themes/colors.dart';

class Background extends StatefulWidget {
  final double widthItem1;
  final double widthItem2;
  const Background({super.key, required this.widthItem1, required this.widthItem2});

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
            alignment: Alignment.topLeft,
            width: widget.widthItem1,
            decoration: BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.primaryColor.withOpacity(0.1), width: 2))
            ),
            child: Column(
              children: [
                Text(
                  'Producto',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Divider(color: AppColors.primaryColor.withOpacity(0.1), thickness: 2)
              ],
            )
        ),
        Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
            alignment: Alignment.topLeft,
            width: widget.widthItem2,
            decoration: BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.primaryColor.withOpacity(0.1), width: 2))
            ),
            child: Column(
              children: [
                Text(
                  'Cant.',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Divider(color: AppColors.primaryColor.withOpacity(0.1), thickness: 2)
              ],
            )
        ),
        Expanded(child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Text(
                  'Precio',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                Divider(color: AppColors.primaryColor.withOpacity(0.1), thickness: 2)
              ],
            )
        ),),
      ],
    );
  }
}
