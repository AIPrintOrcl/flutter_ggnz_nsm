import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/guide/guide_page.dart';
import 'package:ggnz/presentation/pages/guide/guide_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_bank.dart';
import 'package:ggnz/presentation/widgets/buttons/button_coins.dart';
import 'package:ggnz/presentation/widgets/buttons/button_collecting.dart';
import 'package:ggnz/presentation/widgets/buttons/button_inventory.dart';
import 'package:ggnz/presentation/widgets/buttons/button_market.dart';
import 'package:ggnz/presentation/widgets/buttons/button_sound.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_view_widget.dart';
import 'package:ggnz/presentation/widgets/watch.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class IncubatorPage extends StatelessWidget {
  const IncubatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IncubatorPageController());
    final bgmAudioController = Get.find<BgmController>();
    final guidePageController = Get.put(GuidePageController());

    bgmAudioController.bgmOpenAudioPlayer(
        url: bgmAudioController.backgroundStateBgm);
    return Scaffold(
      body: Obx(() {
        if (!guidePageController.isSeenGuide) { /* 올체니즈 성장 가이드 화면 표시 */
          return GuidePage();
        }
        return AnimatedSwitcher( /* 잠 깨우기/포기하다 버튼 */
            duration: Duration(seconds: controller.eggAwake ? 0 : 1), /* 알이 잠에서 깬 여부 */
            switchInCurve: Curves.easeInOut, /* 시작할 때 천천히 시작하고, 중간에 속도가 빨라지다가 끝날 때 다시 천천히 끝나는 애니메이션 효과 */
            child: controller.eggAwake
                ? const EggAwake() /* 잠 깨우기 버튼 실행 */
                : controller.isBackgroundTransition /* 환경게이지 변수에 따른 배경이미지 트랜지션 상태 */
                    ? const EnvironmentChange() /* 환경게이지로 인해 배경이미지 변경할 경우 */
                    : controller.isPartsTransition  /* 파츠 성장 진화시 트랜지션 이미지 상태 */
                        ? const PartsTransition( /* 파츠 성장 구간별 게이지가 진화 조건에 충족하여 파츠 성장 진화 할 경우 진화 관련 효과음 및 애니메이션 표시 */
                            key: Key('Parts Transition'),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    AssetImage(controller.backgroundStateImage),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).padding.top),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: const [
                                    SepticTank(),
                                    IncubatorMenus(),
                                  ],
                                ),
                                Expanded(child: PageViewWidget()),
                                SizedBox(
                                    height: Get.mediaQuery.padding.bottom + 20),
                              ],
                            )
            )
        );
      }),
    );
  }
}

// 환경변화 발생할 경우 관련 효과음 및 애니메이션 표시
class EnvironmentChange extends StatelessWidget {
  const EnvironmentChange({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final environmentChangeAudioController =
        Get.find<EnvironmentChangeAudioController>();
    final bgmAudioController = Get.find<BgmController>();
    environmentChangeAudioController.openAudioPlayer(
        url: 'assets/sound/environment_transition.mp3');
    bgmAudioController.stopAndPlayBgm(playTime: 4);
    return Container(
      height: Get.height,
      width: Get.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/transition/environment_transition.gif'), /* 환경변화 로고 애니메이션 gif */
        ),
      ),
    );
  }
}

// 파츠 성장 구간별 게이지가 진화 조건에 충족하여 파츠 성장 진화 할 경우 진화 관련 효과음 및 애니메이션 표시
class PartsTransition extends StatelessWidget {
  const PartsTransition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final incubatorController = Get.find<IncubatorPageController>();
    final environmentChangeAudioController =
        Get.find<EnvironmentChangeAudioController>();
    final bgmAudioController = Get.find<BgmController>();
    environmentChangeAudioController.openAudioPlayer(
        url: 'assets/sound/environment_transition.mp3');
    bgmAudioController.stopAndPlayBgm(playTime: 4);
    return Obx(
      () => Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            fit: BoxFit.contain,
            image: AssetImage(
                'assets/transition/parts_transition${incubatorController.partsTransitionNumber}.gif'), /* 파츠별로 애니메이션 gif */
          ),
        ),
      ),
    );
  }
}

// 잠 깨우기 버튼 실행할 경우 애니메이션 표시
class EggAwake extends StatelessWidget {
  const EggAwake({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eggStateController = Get.find<EggStateAudioController>();
    final bgmAudioController = Get.find<BgmController>();
    eggStateController.openAudioPlayer(url: 'assets/sound/egg_awake.mp3');
    bgmAudioController.stopAndPlayBgm(playTime: 4);

    return Container(
      height: Get.height,
      width: Get.width,
      decoration: const BoxDecoration(
        color: Colors.grey,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/transition/egg_awake.gif'), /* 알이 잠에서 깬 gif */
        ),
      ),
    );
  }
}

class SepticTank extends StatelessWidget {
  const SepticTank({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            "assets/septic_tank.gif",
            width: 150,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(top: 55),
              width: 110,
              height: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(getx.environmentLevel < 240
                          ? HexColor("#FC8970")
                          : getx.environmentLevel < 480
                              ? HexColor("#FFE177")
                              : HexColor("#6AE485")),
                  value: getx.environmentLevel / 600,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                margin: const EdgeInsets.only(top: 55),
                width: 110,
                height: 20,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 1, color: HexColor("#56B490")))),
                        )),
                    Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 1, color: HexColor("#56B490")))),
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    )
                  ],
                )),
          ),
          Positioned(top: 90, child: Watch(isDialog: false))
        ],
      ),
    );
  }
}

class IncubatorMenus extends StatelessWidget {
  const IncubatorMenus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top, 20, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      ButtonCoins(
                          coinAmount: getx.bait.value,
                          imageUrl: "assets/coin/bait.png",
                          isInt: true),
                      const SizedBox(height: 5),
                      ButtonCoins(
                        coinAmount: getx.ggnz.value,
                        imageUrl: "assets/coin/ggnz.png",
                        isInt: false,
                      ),
                      const SizedBox(height: 5),
                      /*ButtonCoins(
                        coinAmount: getx.klay.value,
                        imageUrl: "assets/coin/klay.png",
                        isInt: false,
                      ),
                      const SizedBox(height: 5),*/
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      ButtonMarket(),
                      ButtonInventory(),
                      ButtonBank(),
                      ButtonCollecting(),
                      ButtonSound(),
                    ],
                  )
                ]),
          ),
        ],
      ),
    );
  }
}
