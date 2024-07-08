import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class ButtonItem extends StatelessWidget {
  final String imageUrl;
  final bool isActive;
  final int amount;
  const ButtonItem(
      {Key? key,
      required this.imageUrl,
      required this.isActive,
      required this.amount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                width: 2,
                color: isActive ? HexColor('#009B5C') : HexColor("#EAEAEA")),
            boxShadow: [
              BoxShadow(
                  color: isActive ? HexColor('#009B5C') : HexColor("#EAEAEA"),
                  offset: const Offset(0, 4))
            ]),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
                child: Image.asset(
              imageUrl,
              width: Get.width / 8,
              color: amount == 0 ? Colors.white.withOpacity(0.4) : null,
              colorBlendMode: amount == 0 ? BlendMode.modulate : null,
            )),
            Positioned(
                top: -5,
                left: -5,
                child: CircleAvatar(
                  backgroundColor: HexColor("#FC8970"),
                  radius: 10,
                  child: Text(
                    '$amount',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                )),
            isActive
                ? Positioned(
                    bottom: -5,
                    right: -5,
                    child: Icon(
                      Icons.check_circle,
                      color: HexColor("#009B5C"),
                    ))
                : Container()
          ],
        ));
  }
}
