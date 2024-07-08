import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:hexcolor/hexcolor.dart';

class GiveUpDialog extends StatelessWidget {
  const GiveUpDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final incubatorPageController = Get.find<IncubatorPageController>();
    return GestureDetector(
      onTap: (() => Get.back()),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/notice_paper.png'),
                fit: BoxFit.contain)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: HexColor("#555D42"),
                height: 1.3,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
              child: Text(
                '정말로\n포기하시겠습니까?',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: HexColor("#555D42"),
                height: 1.3,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              child: Text(
                '키우던 올챙이가 사라지며\n보상을 받을 수 없습니다.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ButtonGGnz(
                buttonText: 'yes'.tr,
                width: 179,
                buttonBorderColor: HexColor("#555D42"),
                buttonColor: HexColor("#DAEAD4"),
                isBoxShadow: true,
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  color: HexColor("#555D42"),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                onPressed: () {
                  incubatorPageController.reset();
                  Get.back();
                }),
            const SizedBox(
              height: 20,
            ),
            ButtonGGnz(
                buttonText: 'no'.tr,
                width: 179,
                buttonBorderColor: HexColor("#555D42"),
                buttonColor: HexColor("#DAEAD4"),
                isBoxShadow: true,
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  color: HexColor("#555D42"),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                onPressed: () {
                  Get.back();
                })
          ],
        ),
      ),
    );
  }
}
