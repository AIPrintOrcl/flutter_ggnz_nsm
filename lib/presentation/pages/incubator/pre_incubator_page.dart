import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class PreIncubatorPage extends StatefulWidget {
  const PreIncubatorPage({Key? key}) : super(key: key);

  @override
  State<PreIncubatorPage> createState() => _PreIncubatorPageState();
}

class _PreIncubatorPageState extends State<PreIncubatorPage> {
  bool isWalletTransition = false;

  void moveToNextPage() {
    Get.offAll(() => const IncubatorPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 2000));
  }

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();
    final transitionAudioController = Get.find<TransitionAudioController>();
    return Scaffold(
      body: Container(
          height: Get.height,
          color: HexColor('#EAFAD9'),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  width: Get.width,
                  height: Get.height,
                  child: Image.asset('assets/notice_paper.png')),
              Positioned(
                top: 20,
                bottom: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'made_wallet'.tr, /* made_wallet : 지갑이 만들어졌어요! */
                      style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        color: HexColor('#555D42'),
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    ButtonGGnz(
                        buttonText: 'grow_a_olchaeneez'.tr, /* grow_a_olchaeneez : 올채니즈 키우기 */
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
                        onPressed: () {
                          audioController.openAudioPlayer(
                              url: 'assets/sound/click_menu.mp3');

                          transitionAudioController.openAudioPlayer(
                              url: 'assets/sound/wallet_transition.mp3');
                          Future.delayed(
                              Duration(milliseconds: 1700), moveToNextPage);

                          setState(() {
                            isWalletTransition = true;
                          });
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                  duration: Duration(milliseconds: 1000),
                  switchOutCurve: Curves.easeOut,
                  child: isWalletTransition
                      ? Container(
                          height: Get.height,
                          child: Image.asset(
                            'assets/transition/connect_wallet_transition.gif',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container())
            ],
          )),
    );
  }
}
