import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/themes/colors.dart';
import '../utils/sliverlist/cardProv.dart';

class ProvConfig extends StatefulWidget {
  const ProvConfig({super.key});

  @override
  State<ProvConfig> createState() => _ProvConfigState();
}

class _ProvConfigState extends State<ProvConfig> {

  List<Map<String, dynamic>> prov = [
    {'id':1, 'name': 'Coca Cola'},
    {'id':2, 'name': 'Marinela'},
    {'id':3, 'name': 'Gamesa'},
    {'id':4, 'name': 'Sabritas'},
    {'id':5, 'name': 'Barcel'}
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors3.whiteColor,
          appBar: AppBar(
            backgroundColor: AppColors3.whiteColor,
            leadingWidth: MediaQuery.of(context).size.width,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                            CupertinoIcons.chevron_back, size: MediaQuery.of(context).size.width * 0.08,
                            color: AppColors3.primaryColor
                        )
                    ),
                    Text(
                        'Proveedores',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors3.primaryColor,
                          fontSize: MediaQuery.of(context).size.width * 0.065,
                        )
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                  child: IconButton(
                    onPressed: () {

                    },
                    icon: const Icon(
                        CupertinoIcons.add,
                      color: AppColors3.primaryColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.01,
                    left: MediaQuery.of(context).size.width * 0.01
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    return CardProv(prov: prov, index: index);
                  },
                      childCount: prov.length
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
