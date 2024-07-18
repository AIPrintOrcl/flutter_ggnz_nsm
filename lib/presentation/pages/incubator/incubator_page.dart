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
        return AnimatedSwitcher( /// AnimatedSwitcher : 위젯 간의 전환을 애니메이션으로 처리하는 데 사용되는 위젯.
            duration: Duration(seconds: controller.eggAwake ? 0 : 1), /* 알이 잠에서 깬 여부 */ /// Duration : 시간 간격을 나타내는 다양한 속성과 메서드를 제공
            switchInCurve: Curves.easeInOut, ///easeInOut : 시작할 때 천천히 시작하고, 중간에 속도가 빨라지다가 끝날 때 다시 천천히 끝나는 애니메이션 효과
            child: controller.eggAwake
                ? const EggAwake() /* 알이 잠에서 깬 애니메이션 실행 */
                : controller.isBackgroundTransition /* 환경게이지 변수에 따른 배경이미지 트랜지션 상태 */
                    ? const EnvironmentChange() /* 환경게이지로 인해 배경이미지 변경할 경우 */
                    : controller.isPartsTransition  /* 파츠 성장 진화시 트랜지션 이미지 상태 */
                        ? const PartsTransition( /* 파츠 성장 구간별 게이지가 진화 조건에 충족하여 파츠 성장 진화 할 경우 진화 관련 효과음 및 애니메이션 표시 */
                            key: Key('Parts Transition'),
                          )
                        : Container( /// Container : 위젯
                            decoration: BoxDecoration( /// decoration : 위젯의 외형을 꾸미는 데 사용. BoxDecoration : 다양한 배경과 테두리를 설정
                              image: DecorationImage( /// DecorationImage : 이미지로 박스를 장식하기 위한 도구. 이미지의 위치, 반복, 크기 조절 등 다양한 속성을 설정 */
                                fit: BoxFit.cover, /// BoxFit fit : 이미지가 박스 내에서 어떻게 맞춰질지를 정의 */
                                image:
                                    AssetImage(controller.backgroundStateImage), /* 환경게이지에 스트림 배경 이미지 변경 변수 & 함수 */
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).padding.top), /// MediaQuery : 화면 크기, 방향, 해상도, 시스템 UI 등의 정보를 자식 위젯에 제공하는 데 사용되는 위젯
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: const [
                                    SepticTank(), /* 정화조(환경게이지 표시) */
                                    IncubatorMenus(), /* 게임 메인 화면 좌측상단(미끼, ggnz)과 우측상단 메뉴(상점, 인벤토리 지갑, 도감 & 콜렉션, 소리) */
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

// 알이 잠에서 깬 애니메이션 실행
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

// 정화조(환경게이지 표시)
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
            "assets/septic_tank.gif", /* 정화조 gif */
            width: 150,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(top: 55),
              width: 110,
              height: 20,
              child: ClipRRect( /// ClipRRect : 자식 위젯을 둥근 모서리를 가진 직사각형 형태로 표시
                borderRadius: BorderRadius.circular(5), ///borderRadius : 클립할 직사각형의 모서리를 둥글게 만드는 데 사용
                child: LinearProgressIndicator( /* 환경게이지 진행바 */ ///LinearProgressIndicator : 수평 진행 바를 나타내는 위젯
                  backgroundColor: Colors.white,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(getx.environmentLevel < 240 /* 현재 환경게이지 < 240(환경게이지 나쁨)일 경우 */
                          ? HexColor("#FC8970") /* 환경게이지 나쁨 = 연한 빨강색 */
                          : getx.environmentLevel < 480 /* 현재 환경게이지 < 480(환경게이지 보통)일 경우 */
                              ? HexColor("#FFE177") /* 환경게이지 보통 = 연한 노랑색 */
                              : HexColor("#6AE485")), /* 환경게이지 좋음 = 연한 초록색 */
                  value: getx.environmentLevel / 600, /* 진행바 = 현재 환경게이지 / 600(환경게이지 좋음). 최소 0부터 최대 1 */
                ),
              ),
            ),
          ),
          Align( /* 환경게이지 나쁨/보통/좋음 경계선 */
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
                                      width: 1, color: HexColor("#56B490")))), /* 진한 초록색 */
                        )),
                    Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 1, color: HexColor("#56B490")))), /* 진한 초록색 */
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    )
                  ],
                )),
          ),
          Positioned(top: 90, child: Watch(isDialog: false)) /// Positioned : Stack 위젯의 자식으로만 사용 가능. 자식 위젯을 Stack의 상단, 하단, 왼쪽, 오른쪽 및 중간에 배치.
        ],
      ),
    );
  }
}

// 게임 메인 화면 좌측상단(미끼, ggnz 코인)과 우측상단 메뉴(상점, 인벤토리 지갑, 도감 & 콜렉션, 소리)
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
                  Column( /* 좌측상단(미끼, ggnz 코인) */
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      ButtonCoins(
                          coinAmount: getx.bait.value,
                          imageUrl: "assets/coin/bait.png", /* 미끼 코인 이미지 */
                          isInt: true),
                      const SizedBox(height: 5),
                      ButtonCoins(
                        coinAmount: getx.ggnz.value,
                        imageUrl: "assets/coin/ggnz.png", /* ggnz 코인 이미지*/
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
                  Column( /* 우측상단 메뉴(상점, 인벤토리 지갑, 도감 & 콜렉션, 소리) */
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      ButtonMarket(), /* 상점 아이콘 버튼 */
                      ButtonInventory(), /* 인벤토리 아이콘 버튼 */
                      ButtonBank(), /* 지갑 아이콘 버튼 */
                      ButtonCollecting(), /* 도감 & 콜렉션 아이콘 버튼 */
                      ButtonSound(), /* 소리 아이콘 버튼 */
                    ],
                  )
                ]),
          ),
        ],
      ),
    );
  }
}
