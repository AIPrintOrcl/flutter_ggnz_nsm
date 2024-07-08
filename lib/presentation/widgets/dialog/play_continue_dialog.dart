import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:async';
import 'package:ntp/ntp.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayContinueDialog extends StatelessWidget {
  const PlayContinueDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playContinueDialogController = Get.put(PlayContinueDialogController());
    final incubatorController = Get.put(IncubatorPageController());
    final FirebaseFirestore db = FirebaseFirestore.instance;

    return Obx(
      () => WillPopScope(
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
                    '다른 어플을 사용하여\n성장이 멈췄습니다.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 40,
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
                    '다시 [이어하기] 버튼을 눌러주세요.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Stack(
                  children: [
                    ButtonGGnz(
                        buttonText: '환경도 +20 올리기',
                        imageUrl: 'assets/ad_icon.png',
                        imageUrlUnderText:
                        playContinueDialogController.getNumOfViews(),
                        width: 200,
                        height: 60,
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
                          if (getx.timer.delayCount.value > 0) {
                            incubatorController.openLoadingDialog();
                            incubatorController.loadAd((ad) async {
                              getx.environmentLevel.value = min(getx.environmentLevel.value + 20, 600);
                              DateTime currentTime = await NTP.now();
                              await getx.timer.updateContinue();

                              Get.back(result: true);
                              incubatorController.lastIsLocked = true;
                              incubatorController.lastUsedTime = currentTime.millisecondsSinceEpoch;
                              incubatorController.closeLoadingDialog();
                            });
                          }
                        }),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ButtonGGnz(
                    buttonText: '그대로 이어하기',
                    width: 200,
                    height: 60,
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
                      Get.back(result: false);
                    })
              ],
            ),
          ),
          onWillPop: () async => false,
      ),
    );
  }
}

class PlayContinueDialogController extends GetxController {
  final _dailyLimit = 3;
  int get dailyLimit => _dailyLimit;

  String getNumOfViews() {
    return '일일제한 ${getx.timer.delayCount.value}/$dailyLimit';
  }
}
