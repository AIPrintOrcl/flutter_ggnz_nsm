import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';

// 로그인 후 현재 진행에 맞게 사용자에게 올채니를 어떻게 할지 메시지로 확인
class SignWalletPage extends StatelessWidget {
  final String signReason;
  const SignWalletPage({Key? key, required this.signReason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final incubatorPageController = Get.find<IncubatorPageController>();
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(url: 'assets/sound/click_paper_notice_in.mp3');
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          color: HexColor('#EAFAD9'),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              SizedBox(
                  width: Get.width,
                  height: Get.height,
                  child: Image.asset('assets/notice_paper.png')),
              Positioned(
                top: 20,
                bottom: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        !["wants_to_buy_egg".tr, "check_egg".tr, "check_dispatch".tr, "check_minting".tr].contains(signReason)?
                        /* 'wants_to_buy_egg': '깨울 알이 없습니다. 알 구매란으로 이동하시겠습니까?'
                        *  'check_egg': '이전에 키우던 올채니를 이어서 키우시겠습니까?'
                        *  'check_dispatch': '방생 중이던 올채니를 이어서 방생하시겠습니까?'
                        *  'check_minting': '입양 중이던 올채니를 이어서 입양 하시겠습니까?'
                        * */
                        '$signReason \n ${'request_permission_to_work'.tr}'
                            : '$signReason',
                        style: TextStyle(
                          height: 1.8,
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: HexColor('#555D42'),
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                    const SizedBox(
                      height: 80,
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
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: () async {
                          var arg = Get.arguments;

                          if (arg["reason"] == 'MINT') {
                            Get.back(result: true);
                            incubatorPageController.setIsDispatchAnimationDone(dispatchAnimationDone: true);
                            incubatorPageController.minting(arg["type"]);
                            return;
                          }
                          if (arg["reason"] == 'dispatch_start') {
                            Get.back(result: true);
                            incubatorPageController.dispatch(arg["amount"]);
                          }
                          if (arg["reason"] == 'egg') {
                            Get.back();
                            incubatorPageController.buyEgg(arg["number"]);
                            return;
                          }
                          if (arg["reason"] == '100' || arg["reason"] == '300') {
                            Get.back();
                            incubatorPageController.buyItem(int.parse(arg["reason"]), true);
                            return;
                          }
                          if (arg["reason"] == 'check_egg') {
                            Get.back(result: true);
                            return;
                          }
                          if (arg["reason"] == 'exchange_coin') {
                            Get.back();
                            Get.back();

                            incubatorPageController.exchangeCoin(arg["from"], arg["to"], arg["amount"]);
                          }
                          if (arg["reason"] == 'private_key_export') {
                            Get.back(result: true);
                          }
                          if (arg["reason"] == 'wants_to_buy_egg') {
                            Get.back(result: true);
                          }
                          if (arg["reason"] == 'get_rewards') {
                            Get.back(result: true);
                          }
                          Get.off(() => const IncubatorPage());
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    ButtonGGnz(
                        buttonText: 'no'.tr,
                        width: 179,
                        buttonBorderColor: Colors.white,
                        buttonColor: Colors.white,
                        isBoxShadow: true,
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: HexColor("#555D42"),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: () {
                          Get.back(result: false);
                        })
                  ],
                ),
              )
            ],
          )),
    );
  }
}
