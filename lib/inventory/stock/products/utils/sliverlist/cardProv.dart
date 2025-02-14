import 'package:flutter/material.dart';

import '../../../../../helpers/themes/colors.dart';

class CardProv extends StatefulWidget {

  final List<Map<String, dynamic>> prov;
  final int index;
  const CardProv({super.key, required this.prov, required this.index});

  @override
  State<CardProv> createState() => _CardProvState();
}

class _CardProvState extends State<CardProv> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal:  MediaQuery.of(context).size.width * 0.02,
          vertical: MediaQuery.of(context).size.width * 0.02),
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width * 0.04,
        horizontal: MediaQuery.of(context).size.width * 0.01,
      ),
      decoration: BoxDecoration(
        color: AppColors3.whiteColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: AppColors3.primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors3.primaryColorMoreStrong.withOpacity(0.1),
            blurRadius: 3,
            spreadRadius: 1,
            offset: const Offset(3, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.035),
              child: Text(
                  widget.prov[widget.index]['name'],
                  style: TextStyle(
                      color: AppColors3.primaryColor,
                      fontSize: MediaQuery.of(context).size.width * 0.0525
                  )
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {

                  },
                  icon: Icon(
                    Icons.edit_document,
                    color: AppColors3.primaryColor,
                    size: MediaQuery.of(context).size.width * 0.065,
                  )
              ),
              IconButton(
                  onPressed: () {

                  },
                  icon: Icon(Icons.delete,
                    color: AppColors3.redDelete,
                    size: MediaQuery.of(context).size.width * 0.065,)
              ),
            ],
          )
        ],
      ),
    );
  }
}
