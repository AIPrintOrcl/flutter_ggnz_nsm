import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';

// 사용자에게 전달할 메시지 내용과 arguments 값에 따라 확인 메시지
class SignWalletPage extends StatelessWidget {
  final String signReason;
  const SignWalletPage({Key? key, required this.signReason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  child: Image.asset('assets/notice_paper.png')), /* 빈 문서 이미지 */
              Positioned(
                top: 20,
                bottom: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        /* 'wants_to_buy_egg': '깨울 알이 없습니다. 알 구매란으로 이동하시겠습니까?'
                        *  'check_egg': '이전에 키우던 올채니를 이어서 키우시겠습니까?'
                        *  'check_dispatch': '방생 중이던 올채니를 이어서 방생하시겠습니까?'
                        *  'check_minting': '입양 중이던 올채니를 이어서 입양 하시겠습니까?'
                        * */
                        !["wants_to_buy_egg".tr, "check_egg".tr, "check_dispatch".tr, "check_minting".tr,
                          "change_user_to_v2_1".tr, "change_user_to_v2_2".tr].contains(signReason)?
                        '$signReason \n ${'request_permission_to_work'.tr}' /* 'request_permission_to_work': '작업 권한을 요청합니다' */
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
                    ButtonGGnz( /* Get.arguments 따른 버튼 실행 */
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
                          if (arg["reason"] == 'check_egg') {
                            Get.back(result: true);
                            return;
                          }
                          if (arg["reason"] == 'private_key_export') {
                            Get.back(result: true);
                            return;
                          }
                          if (arg["reason"] == 'wants_to_buy_egg') {
                            Get.back(result: true);
                            return;
                          }
                          if (arg["reason"] == 'get_rewards') {
                            Get.back(result: true);
                            return;
                          }
                          if (arg['reason'] == 'change_user_to_v2_1' || arg['reason'] == 'change_user_to_v2_2') {
                            Get.back(result: true);
                            return;
                          }

                          final incubatorPageController = Get.find<IncubatorPageController>();

                          if (arg["reason"] == 'MINT') { // '입양하기' 버튼 -> 밍틴을 GGNZ와 민팅권 소비 중 선택 type : 1 = 1000 GGNZ, type : 2 = 민팅권
                            Get.back(result: true);
                            incubatorPageController.setIsDispatchAnimationDone(dispatchAnimationDone: true); // 파견보내기 애니메이션이 모두 완료
                            incubatorPageController.minting(arg["type"]);
                            return;
                          }
                          if (arg["reason"] == 'dispatch_start') { // '방생하기' 버튼을 클릭 했을 경우 [dispatch_dialog.dart]
                            Get.back(result: true);
                            incubatorPageController.dispatch(arg["amount"]);
                          }
                          if (arg["reason"] == 'egg') { // 상점에서 알 구입할 경우
                            Get.back();
                            incubatorPageController.buyEgg(arg["number"]);
                            return;
                          }
                          if (arg["reason"] == '100' || arg["reason"] == '300') { // 상점에서 상자를 구입할 경우
                            Get.back();
                            incubatorPageController.buyItem(int.parse(arg["reason"]), true);
                            return;
                          }
                          if (arg["reason"] == 'exchange_coin') {
                            Get.back();
                            Get.back();

                            incubatorPageController.exchangeCoin(arg["from"], arg["to"], arg["amount"]);
                            return;
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
