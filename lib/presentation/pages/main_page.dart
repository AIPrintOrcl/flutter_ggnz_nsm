import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/credit/credit_page.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/pages/wallet/make_wallet_page.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'dart:io';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  // 알림창
  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dear User'),
          content: const Text(
            'We care about your privacy and data security. We keep this app free by showing ads. '
                'Can we continue to use your data to tailor ads for you?\n\nYou can change your choice anytime in the app settings. '
                'Our partners will collect data and use a unique identifier on your device to show you ads.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

  Future<void> initPlugin(BuildContext context) async {
    final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus; /* 현재 추적 상태 확인 */
    if (status == TrackingStatus.notDetermined) { /* notDetermined : 사용자가 아직 승인 요청 대화 상자를 받지 못한 상태일 경우. */
      // 사용자 정의 추적 대화 상자 표시
      await showCustomTrackingDialog(context);
      await Future.delayed(const Duration(milliseconds: 200));
      // 추적 승인 요청
      final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization(); /* requestTrackingAuthorization : 시스템 대화 상자를 통해 사용자의 추적 승인 요청 */
    }

    // 사용자의 광고 식별자를 uuid애 저장
    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
  }

  @override
  Widget build(BuildContext context) {
    /// IOS일 경우 첫 번째 프레임 화면에 그려진 후 특정 초기화 작업 수행.
    if (Platform.isIOS) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => initPlugin(context));
    }

    final audioController = Get.find<AudioController>();
    final mainPageController = Get.put(MainPageController());
    audioController.openAudioPlayer(url: 'assets/sound/title.mp3');
    return Scaffold(
      body: Obx(
        () => Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/bg2.gif'),
            ),
          ),
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Spacer(flex: 1),
                  mainPageController.isShowTitle
                      ? Image.asset(
                          'assets/title.gif',
                        )
                      : Container(),
                  const Spacer(flex: 1),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 800),
                    switchInCurve: Curves.easeIn,
                    child: mainPageController.isShowButton
                        ? Column(
                            children: [
                              // 시작하기 버튼
                              ButtonGGnz(
                                buttonText: 'start'.tr,
                                width: 179,
                                buttonBorderColor: HexColor('#555D42'),
                                buttonColor: HexColor('#DAEAD4'),
                                isBoxShadow: true,
                                style: TextStyle(
                                  fontFamily: 'ONE_Mobile_POP_OTF',
                                  color: HexColor('#555D42'),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                onPressed: () {
                                  audioController.openAudioPlayer(
                                      url: 'assets/sound/click_menu.mp3');
                                  Get.off(() => const MakeWalletPage(),
                                      transition: Transition.fadeIn,
                                      duration:
                                          const Duration(milliseconds: 500));
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              // Credit 버튼
                              ButtonGGnz(
                                buttonText: 'credit'.tr,
                                width: 179,
                                buttonBorderColor: HexColor('#555D42'),
                                buttonColor: HexColor('#DAEAD4'),
                                isBoxShadow: true,
                                style: TextStyle(
                                  fontFamily: 'ONE_Mobile_POP_OTF',
                                  color: HexColor('#555D42'),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                onPressed: () {
                                  audioController.openAudioPlayer(
                                      url: 'assets/sound/click_menu.mp3');
                                  Get.to(() => const CreditPage(),
                                      transition: Transition.fadeIn,
                                      duration:
                                          const Duration(milliseconds: 500));
                                },
                              ),
                            ],
                          )
                        : Container(height: 50),
                  ),
                  const Spacer(flex: 4),
                ]),
          ),
        ),
      ),
    );
  }
}

class MainPageController extends GetxController {
  RxBool _isShowTitle = false.obs;
  bool get isShowTitle => _isShowTitle.value;
  RxBool _isShowButton = false.obs;
  bool get isShowButton => _isShowButton.value;

  @override
  void onInit() {
    Future.delayed(
        Duration(milliseconds: 300), (() => _isShowTitle.value = true));
    Future.delayed(
        Duration(milliseconds: 1500), (() => _isShowButton.value = true));
    super.onInit();
  }
}
