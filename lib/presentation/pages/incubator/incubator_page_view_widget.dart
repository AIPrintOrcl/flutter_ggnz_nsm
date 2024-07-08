import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/widgets/dialog/dispatch_dialog.dart';
import 'package:ggnz/presentation/widgets/dialog/give_up_dialog.dart';
import 'package:ggnz/presentation/widgets/dialog/go_to_market_dialog.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/utils/launch_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class PageViewWidget extends StatelessWidget {
  const PageViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncubatorPageController>();
    final pageController = PageController();

    return Obx(() {
      return PageView.builder(
          controller: pageController,
          physics: controller.isPlaying || controller.isIncubatorDone
              ? const NeverScrollableScrollPhysics()
              : null,
          itemCount: 3,
          onPageChanged: (value) => controller.setIndicatorCount = value,
          itemBuilder: ((context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                EggTitle(
                  index: index,
                ),
                EggAndMarimoView(
                  index: index,
                  pageController: pageController,
                ),
                IncubatorPageButtonSet(
                  index: index,
                )
              ],
            );
          }));
    });
  }
}

class EggTitle extends StatelessWidget {
  final int index;
  const EggTitle({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncubatorPageController>();
    return Expanded(
      child: Opacity(
        opacity: controller.isPlaying || controller.isIncubatorDone ? 0 : 1,
        child: Container(
            width: 160,
            height: 48,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: index == 0
                    ? HexColor('347A8B')
                    : index == 1
                        ? HexColor('8B345B')
                        : Colors.green),
            child: Center(
                child: Text(
              index == 0
                  ? 'ggnz_egg'.tr
                  : index == 1
                      ? 'special_egg'.tr
                      : 'premium_egg'.tr,
              style: const TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ))),
      ),
    );
  }
}

class EggSleep extends StatelessWidget {
  final int index;
  const EggSleep({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eggStateAudioController = Get.find<EggStateAudioController>();

    eggStateAudioController.openAudioPlayer(
        url: 'assets/sound/egg_sleep.mp3', isLoop: true);

    return Container(
        alignment: Alignment.bottomCenter,
        height: 260,
        child: Image.asset(
          "assets/egg_sleep$index.gif",
          width: 200,
        ));
  }
}

class EggJump extends StatelessWidget {
  final int index;
  const EggJump({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eggStateAudioController = Get.find<EggStateAudioController>();
    eggStateAudioController.openAudioPlayer(
        url: 'assets/sound/egg_jump.mp3', isLoop: true);
    return Container(
        alignment: Alignment.bottomCenter,
        height: 260,
        child: Image.asset(
          "assets/egg$index.gif",
          width: 200,
        ));
  }
}

class MarimoImageStack extends StatefulWidget {
  final List<String> marimoList;
  MarimoImageStack({Key? key, required this.marimoList}) : super(key: key);

  @override
  State<MarimoImageStack> createState() => _MarimoImageStackState();
}

class _MarimoImageStackState extends State<MarimoImageStack> {
  @override
  void dispose() {
    imageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: widget.marimoList
          .where((e) => e != '')
          .map(
            (e) => Image.asset(
              e,
              height: 260,
              fit: BoxFit.cover,
            ),
          )
          .toList(),
    );
  }
}

class EmotionBubble extends StatelessWidget {
  const EmotionBubble({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final incubatorPageController = Get.find<IncubatorPageController>();
    final emotionController = Get.put(EmotionBubbleController());

    return Obx(() {
      if (incubatorPageController.isIncubatorDone) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              emotionController.ready,
              width: Get.width / 3.5,
              fit: BoxFit.contain,
            ),
          ],
        );
      }
      if (incubatorPageController.isPlaying ||
          !emotionController.isShowEmotion) {
        return Container();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset(
            emotionController.emotion,
            width: Get.width / 3.5,
            fit: BoxFit.contain,
          )
        ],
      );
    });
  }
}

class EmotionBubbleController extends GetxController {
  final List<String> badEmotion = [
    'assets/emotion/worst.gif',
    'assets/emotion/angry.gif',
  ];
  final List<String> normalEmotion = [
    'assets/emotion/normal.gif',
    'assets/emotion/sweat.gif'
  ];
  final List<String> goodEmotion = [
    'assets/emotion/good.gif',
    'assets/emotion/excited.gif'
  ];
  RxString _emotion = ''.obs;
  String get emotion => _emotion.value;

  String ready = 'assets/emotion/ready.gif';
  RxInt _emotionNumber = 0.obs;
  RxBool _isShowEmotion = false.obs;
  bool get isShowEmotion => _isShowEmotion.value;

  late Timer listenEnvironmentLevelTimer;

  final emotionAudioController = Get.find<EmotionAudioController>();

  @override
  void onInit() {
    setEmotion();
    listenEnvironmentLevel();
    super.onInit();
  }

  void listenEnvironmentLevel() {
    final incubatorController = Get.find<IncubatorPageController>();

    listenEnvironmentLevelTimer =
        Timer.periodic(const Duration(seconds: 300), (timer) {
      setEmotion();

      if (!incubatorController.isPlaying &&
          !incubatorController.isIncubatorDone) {
        _isShowEmotion.value = true;
        emotionAudioController.openAudioPlayer(
            url: 'assets/sound/emotion_imoticon.mp3');
        Future.delayed(Duration(milliseconds: 1850), () {
          imageCache.clear();
          _isShowEmotion.value = false;
        });
      }
    });
  }

  void setEmotion() {
    _emotionNumber.value = _emotionNumber.value % 2 == 0 ? 1 : 0;
    getx.environmentLevel.value < 240.0
        ? _emotion.value = badEmotion[_emotionNumber.value]
        : getx.environmentLevel.value < 480.0
            ? _emotion.value = normalEmotion[_emotionNumber.value]
            : _emotion.value = goodEmotion[_emotionNumber.value];
  }

  @override
  void onClose() {
    listenEnvironmentLevelTimer.cancel();
    super.onClose();
  }
}

class HealthBubble extends StatelessWidget {
  const HealthBubble({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final incubatorPageController = Get.find<IncubatorPageController>();
    return Obx(
      () => Column(
        children: [
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/heart.gif',
                width: Get.width / 14,
              ),
              const SizedBox(
                width: 10,
              ),
              Stack(
                children: <Widget>[
                  Text(
                    incubatorPageController.healthLevel.toInt().toString(),
                    style: TextStyle(
                      fontFamily: 'ONE_Mobile_POP_OTF',
                      fontSize: 16,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = HexColor('#555D42'),
                    ),
                  ),
                  Text(
                    incubatorPageController.healthLevel.toInt().toString(),
                    style: TextStyle(
                      fontFamily: 'ONE_Mobile_POP_OTF',
                      fontSize: 16,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 3, color: HexColor("#555D42"))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Obx(
                () => LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Colors.black26,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(HexColor("#6AE485")),
                  value: incubatorPageController.partsGage == 0.0 ||
                          incubatorPageController.maxPartsGage == 0.0
                      ? 0.0
                      : incubatorPageController.partsGage /
                          incubatorPageController.maxPartsGage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnlyGopOrGogText extends StatelessWidget {
  final index;
  const OnlyGopOrGogText({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/lock.png',
        ),
        Stack(
          children: <Widget>[
            Text(
              index == 1
                  ? 'need_gop'.tr
                  : index == 2
                      ? 'need_gog'.tr
                      : '',
              style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                fontSize: 14,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = HexColor('#555D42'),
              ),
            ),
            Text(
              index == 1
                  ? 'need_gop'.tr
                  : index == 2
                      ? 'need_gog'.tr
                      : '',
              style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                fontSize: 14,
                color: Colors.grey[100],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EggAndMarimoView extends StatelessWidget {
  final index;
  final PageController pageController;
  const EggAndMarimoView(
      {Key? key, required this.index, required this.pageController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncubatorPageController>();
    return Obx(() => Expanded(
          flex: 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (controller.arrangementItemImage.isNotEmpty)
                ArrangementItemImage(
                  imageURL: controller.arrangementItemImage,
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeInOut,
                child: controller.marimoList[0].isEmpty &&
                        !controller.isPlaying &&
                        !controller.isDispatchAnimationDone
                    ? Container()
                    : controller.marimoList[0].isEmpty &&
                            !controller.isPlaying &&
                            controller.isDispatchAnimationDone
                        ? EggSleep(
                            key: Key('eggSleepKey' + index.toString()),
                            index: index)
                        : controller.marimoList[0].isEmpty &&
                                controller.isPlaying
                            ? EggJump(
                                key: Key('eggJumpKey' + index.toString()),
                                index: index)
                            : controller.isPartsTransition
                                ? Container(
                                    key: Key('emptyContainerKey'),
                                  )
                                : Container(
                                    key: const Key('marimoStackKey'),
                                    alignment: Alignment.bottomCenter,
                                    height: 260,
                                    child: MarimoImageStack(
                                        marimoList: controller.marimoList)),
              ),
              controller.isPlaying || controller.isIncubatorDone
                  ? Container()
                  : Positioned(
                      width: Get.width,
                      top: Get.height / 5,
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  if (controller.indicatorCount == 0) {
                                    return;
                                  }
                                  controller.setIsPageViewClick();
                                  pageController.previousPage(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.linear);
                                },
                                child: Opacity(
                                  opacity: controller.isPageViewClick
                                      ? 0
                                      : controller.indicatorCount == 0
                                          ? 0.5
                                          : 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 2,
                                            color: HexColor('555D42'))),
                                    child: Container(
                                      child: CircleAvatar(
                                          backgroundColor: HexColor('DAEAD4'),
                                          child: Icon(Icons.arrow_left,
                                              size: 35,
                                              color: HexColor('555D42'))),
                                    ),
                                  ),
                                )),
                            GestureDetector(
                                onTap: () {
                                  if (controller.indicatorCount == 2) {
                                    return;
                                  }

                                  controller.setIsPageViewClick();
                                  pageController.nextPage(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.linear);
                                },
                                child: Opacity(
                                  opacity: controller.isPageViewClick
                                      ? 0
                                      : controller.indicatorCount == 2
                                          ? 0.5
                                          : 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 2,
                                            color: HexColor('555D42'))),
                                    child: CircleAvatar(
                                        backgroundColor: HexColor('DAEAD4'),
                                        child: Icon(
                                          Icons.arrow_right,
                                          size: 35,
                                          color: HexColor('555D42'),
                                        )),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
              Positioned(
                width: Get.width,
                bottom: controller.isIncubatorDone
                    ? Get.height / 5
                    : Get.height / 6,
                right:
                    controller.isIncubatorDone ? Get.width / 6 : Get.width / 5,
                child: EmotionBubble(),
              ),
            ],
          ),
        ));
  }
}

class IncubatorPageButtonSet extends StatelessWidget {
  final index;
  const IncubatorPageButtonSet({Key? key, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncubatorPageController>();
    final audioController = Get.find<AudioController>();
    return Obx(() => Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: index == 0 ||
                        controller.isPlaying ||
                        (index == 1 && getx.gop.value > 0) ||
                        (index == 2 && getx.gog.value > 0)
                    ? HealthBubble()
                    : OnlyGopOrGogText(index: index),
              ),
              /*Expanded(
                child: ButtonGGnz(
                  isOpacity: index == 0 ? true : false,
                  textWidget: RichText(
                    text: TextSpan(
                        text: controller.indicatorCount == 1 ? 'GOP' : 'GOG',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'ONE_Mobile_POP_OTF',
                            color: controller.indicatorCount == 1
                                ? HexColor('8B345B')
                                : Colors.green),
                        children: [
                          TextSpan(
                              text: ' 보러가기',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'ONE_Mobile_POP_OTF',
                                color: HexColor("#555D42"),
                              ))
                        ]),
                  ),
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
                    controller.indicatorCount == 1
                        ? launchURL(
                            'https://opensea.io/collection/gaeguneez-of-the-planet')
                        : launchURL(
                            'https://opensea.io/collection/gaeguneez-of-the-galaxy');
                  },
                ),
              ),*/
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: ButtonGGnz(
                  buttonText: controller.isPlaying
                      ? '포기하기'
                      : controller.isIncubatorDone
                          ? 'growth_complete'.tr
                          : 'wake_up'.tr,
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
                    if (controller.isIncubatorDone) {
                      audioController.openAudioPlayer(
                          url: 'assets/sound/click_menu.mp3');
                      Get.dialog(const DispatchDialog(),
                          transitionCurve: Curves.decelerate,
                          transitionDuration: const Duration(milliseconds: 500));
                      return;
                    }

                    if (!controller
                        .indicatorCountState[controller.indicatorCount]!) {
                      audioController.openAudioPlayer(
                          url: 'assets/sound/click_menu.mp3');
                      Get.dialog(GoToMarketDialog());
                      return;
                    }

                    if (!controller.isPlaying) {
                      controller.checkStartingServer();
                    }

                    if (controller.isPlaying) {
                      audioController.openAudioPlayer(
                          url: 'assets/sound/click_menu.mp3');
                      Get.dialog(GiveUpDialog());
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              )
            ],
          ),
        ));
  }
}

class ArrangementItemImage extends StatelessWidget {
  final imageURL;
  const ArrangementItemImage({Key? key, required this.imageURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        child: Container(
      padding: EdgeInsets.symmetric(
          horizontal: Get.width / 8, vertical: Get.height / 15),
      alignment: Alignment.topRight,
      child: Image.asset(
        imageURL,
        width: Get.width / 4,
      ),
    ));
  }
}
