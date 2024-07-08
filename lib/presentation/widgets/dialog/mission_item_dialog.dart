import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class MissionItemDialog extends StatelessWidget {
  final String imageUrl;
  final String itemName;
  const MissionItemDialog(
      {Key? key, required this.imageUrl, required this.itemName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/notice_paper.png',
                fit: BoxFit.cover,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 5),
                  DefaultTextStyle(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.5,
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: HexColor('#555D42'),
                      ),
                      child: Text('미션을 성공하여\n$itemName을 획득하셨습니다.')),
                  Image.asset(
                    imageUrl,
                    width: Get.height / 4,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DefaultTextStyle(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: HexColor('#555D42'),
                      ),
                      child: Text(itemName)),
                  const Spacer(flex: 5),
                ],
              ),
            ]),
      ),
    );
  }
}
