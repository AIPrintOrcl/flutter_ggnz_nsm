import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Image(
                  image: AssetImage('assets/loading_image.gif'),
                ),
              )
          ),
        ),
        onWillPop: () async => false,
    );
  }

}