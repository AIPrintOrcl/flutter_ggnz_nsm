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
    final pageController = PageController(); /// PageController : PageView 위젯과 함께 사용되어 페이지 기반의 스크롤링을 제어하는 데 사용되는 컨트롤러. 프로그래밍 방식으로 페이지를 이동하거나 현재 페이지의 위치를 얻을 있다.

    return Obx(() {
      return PageView.builder(
          controller: pageController,
          physics: controller.isPlaying || controller.isIncubatorDone /* 분양하기 버튼으로 분양 받은 상태 || 파츠 성장 완료 상태일 경우 */
              ? const NeverScrollableScrollPhysics() /// NeverScrollableScrollPhysics : 스크롤이 전혀 불가능한 영역 : 스크롤이 전혀 불가능한 영역
              : null,
          itemCount: 3,
          onPageChanged: (value) => controller.setIndicatorCount = value, /* 알 별 현재 출력 페이지 인디케이터 체크 변수에 값 저장?? */
          itemBuilder: ((context, index) { /* 인덱스 = 1 : 보통알, 2 : 특별한알, 3 : 프리미엄알 */
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                EggTitle( // 인덱스에 따른 알 이름과 색 표시
                  index: index,
                ),
                EggAndMarimoView( /* 인덱스에 따른 알 또는 마리모 상태의 캐릭터 */
                  index: index,
                  pageController: pageController,
                ),
                IncubatorPageButtonSet( /* 건강도 및 gop/gog 잠금 위젯과 깨우기/포기하기 버튼 */
                  index: index,
                )
              ],
            );
          }));
    });
  }
}

// 인덱스에 따른 알 이름과 색 표시
class EggTitle extends StatelessWidget {
  final int index; /* 0 : 보통 알, 1 : 특별한 알, 2 : 프리미엄 알 */
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
                color: index == 0 /* 보통 알 */
                    ? HexColor('347A8B') /* 진녹색 */
                    : index == 1 /* 특별한 알 */
                        ? HexColor('8B345B') /* 진한 자주색 */
                        : Colors.green), /* 프리미엄 알 - 그린 */
            child: Center(
                child: Text(
              index == 0
                  ? 'ggnz_egg'.tr /* 'ggnz_egg': '보통 알' */
                  : index == 1
                      ? 'special_egg'.tr /* 'special_egg': '특별한 알' */
                      : 'premium_egg'.tr, /* 'premium_egg': '프리미엄 알' */
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

// 인덱스에 따른 알이 자고 있는 애니메이션 및 배경음.
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
          "assets/egg_sleep$index.gif", /* 보통알/특별알/프리미엄알 잠자는 알 gif */
          width: 200,
        ));
  }
}

// 인덱스에 따른 알이 깬 상태에서 점프하는 애니메이션 및 배경음
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

// 성장 단계별 마리모 이미지 누적 변수를 Stack으로 가져오기 위함
class MarimoImageStack extends StatefulWidget {
  final List<String> marimoList; /* marimoList : 성장 단계별 마리모 이미지 누적 변수 */
  MarimoImageStack({Key? key, required this.marimoList}) : super(key: key);

  @override
  State<MarimoImageStack> createState() => _MarimoImageStackState(); /* createState() 사용처 ?? */
}

class _MarimoImageStackState extends State<MarimoImageStack> {
  @override
  void dispose() {
    imageCache.clear();
    super.dispose(); /* Flutter의 State 클래스나 GetxController 등에서 리소스를 정리하고 메모리 누수를 방지하기 위해 사용 */
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter, /// AlignmentDirectional.bottomCenter : 자식 위젯들이 Stack의 하단 중앙에 정렬
      children: widget.marimoList
          .where((e) => e != '') /* marimoList 값이 빈 값이 아닐 때 */
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

// 마리모의 현재 상태[나쁨/보통/좋음]에 따라 말풍선으로 감정표현을 나타냄.
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
              emotionController.ready, /* 말풍선 READY 표시 gif */
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

// 마리모의 현재 상태[나쁨/보통/좋음]에 따라 말풍선으로 감정표현을 나타내는 컨트롤러
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
    'assets/emotion/good.gif', /* 말풍선 하트 표시 gif */
    'assets/emotion/excited.gif'
  ];
  RxString _emotion = ''.obs;
  String get emotion => _emotion.value;

  String ready = 'assets/emotion/ready.gif'; /* 말풍선 READY 표시 gif */
  RxInt _emotionNumber = 0.obs; /* 0, 1을 반복 => 감정 표현을 순차적으로 반복 실행하기 위함 */
  RxBool _isShowEmotion = false.obs; /* 감정 표현이 보여주는 여부 */
  bool get isShowEmotion => _isShowEmotion.value;

  late Timer listenEnvironmentLevelTimer; /* 환경 레벨의 주기적인 업데이트를 위해 사용 ?? */

  final emotionAudioController = Get.find<EmotionAudioController>();

  @override
  void onInit() {
    setEmotion(); /* 마리모 상태에 따라 감정 표현을 순차적으로 반복 실행 */
    listenEnvironmentLevel(); /* 환경 레벨에 주기적인 업데이트를 통해 감정을 업데이트하고 부화하지 않고 파츠 성장이 미완료된 상태에서는 감정 표현을 숨긴다. */
    super.onInit();
  }

  // 환경 레벨에 주기적인 업데이트를 통해 감정을 업데이트하고 부화하지 않고 파츠 성장이 미완료된 상태에서는 감정 표현을 숨긴다.
  void listenEnvironmentLevel() {
    final incubatorController = Get.find<IncubatorPageController>();

    listenEnvironmentLevelTimer =
        Timer.periodic(const Duration(seconds: 300), (timer) { /* 5분 간격으로 반복 실행되는 작업을 설정 */
      setEmotion(); /* 환경 레벨 따라 주기적인 감정을 업데이트하기 위함 */

      if (!incubatorController.isPlaying && /* 부화하지 않고 */
          !incubatorController.isIncubatorDone) { /* 파츠 성장 미완료된 상태 일 경우 */
        _isShowEmotion.value = true; /* 감정 표현을 보여줌 */
        emotionAudioController.openAudioPlayer(
            url: 'assets/sound/emotion_imoticon.mp3');
        Future.delayed(Duration(milliseconds: 1850), () { /* 1.85초 지연 후 실행 */ /// Future.delayed : 지정된 시간 동안 지연된 후에 실행할 작업을 정의하는 데 사용
          imageCache.clear(); /* 이미지 캐시를 비워 메모리 사용을 최적화 */
          _isShowEmotion.value = false; /* 감정 표현을 안 보여줌 */
        });
      }
    });
  }

  // 마리모 상태에 따라 감정 표현을 순차적으로 반복 실행
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

// 마리모의 건강도 숫자와 게이지 위젯
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
                'assets/heart.gif', /* 하트가 두근두근 애니메이션 gif */
                width: Get.width / 14,
              ),
              const SizedBox(
                width: 10,
              ),
              Stack(
                children: <Widget>[
                  // 건강도 숫자 표시
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
          // 건강도 게이지
          Container(
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 3, color: HexColor("#555D42"))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Obx(
                () => LinearProgressIndicator( /// LinearProgressIndicator : Flutter에서 진행 상황을 시각적으로 표시하기 위한 위젯
                  minHeight: 6,
                  backgroundColor: Colors.black26,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(HexColor("#6AE485")),
                  value: incubatorPageController.partsGage == 0.0 ||
                          incubatorPageController.maxPartsGage == 0.0
                      ? 0.0
                      : incubatorPageController.partsGage /
                          incubatorPageController.maxPartsGage, /* 현재 게이지 / max 게이지 */
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// gop/gog 전용 아닐 경우 잠금 위젯
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
          'assets/lock.png', /* 자물쇠 이미지 */
        ),
        Stack(
          children: <Widget>[
            Text( /* 밑에 초록 글찌 */
              index == 1 /* 특별한 알일 경우 */
                  ? 'need_gop'.tr  /* 'need_gop': 'GOP 전용' */
                  : index == 2 /* 프리미엄한알 */
                      ? 'need_gog'.tr /* 'need_gog': 'GOG 전용' */
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
            Text( /* 앞에 흰 글지 */
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
/* 인덱스에 따른 알 또는 마리모 상태의 캐릭터 */
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
              if (controller.arrangementItemImage.isNotEmpty) /* 배치 아이템 이미지명을 없을 경우 */
                ArrangementItemImage(
                  imageURL: controller.arrangementItemImage,
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500), /// Duration : 시간 간격을 나타내는 다양한 속성과 메서드를 제공
                switchInCurve: Curves.easeInOut, ///easeInOut : 시작할 때 천천히 시작하고, 중간에 속도가 빨라지다가 끝날 때 다시 천천히 끝나는 애니메이션 효과
                child: controller.marimoList[0].isEmpty && /* 성장 단계별 마리모 이미지 누적 변수가 빈 값일 경우 */
                        !controller.isPlaying && /* 부화 상태가 아닐 경우*/
                        !controller.isDispatchAnimationDone /* 파견보내기 애니메이션이 모두 미완료일 경우 */
                    ? Container() /* 아무일도 안 일어남 */
                    : controller.marimoList[0].isEmpty && /* 빈 값 */
                            !controller.isPlaying && /* 부화 상태가 아닐 때 */
                            controller.isDispatchAnimationDone /* 파견보내기 애니메이션이 모두 완료 상태 */
                        ? EggSleep( /* 알이 자고 있는 애니메이션 및 배경음. */
                            key: Key('eggSleepKey' + index.toString()), /* 키 값 사용처 ?? */
                            index: index)
                        : controller.marimoList[0].isEmpty && /* 빈 값 */
                                controller.isPlaying /* 부화 상태일 때 */
                            ? EggJump( /* 인덱스에 따른 알이 깬 상태에서 점프하는 애니메이션 및 배경음 */
                                key: Key('eggJumpKey' + index.toString()),
                                index: index)
                            : controller.isPartsTransition /* 파츠 성장 진화시 트랜지션 이미지 상태 */
                                ? Container(
                                    key: Key('emptyContainerKey'),
                                  )
                                : Container(
                                    key: const Key('marimoStackKey'),
                                    alignment: Alignment.bottomCenter,
                                    height: 260,
                                    child: MarimoImageStack( /* 성장 단계별 마리모 이미지 누적 변수를 Stack으로 가져오기 위함 */
                                        marimoList: controller.marimoList)), /* marimoList : 성장 단계별 마리모 이미지 누적 변수 */
              ),
              controller.isPlaying || controller.isIncubatorDone /* 부화 상태 또는 파츠 성장 완료 상태 일 경우 */
                  ? Container() /* 아무일도 안 일어남 */
                  : Positioned( /// Positioned : Stack 위젯의 자식 위젯이 어디에 위치할지를 제어하는 위젯입니다. Positioned는 자식 위젯의 위치와 크기를 지정할 수 있습니다.
                      width: Get.width,
                      top: Get.height / 5,
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector( ///GestureDetector : Flutter에서 사용자 제스처를 감지하고 처리하는 위젯. 사용자의 터치, 스와이프, 탭, 드래그 등의 다양한 제스처를 감지하고 해당 제스처에 따라 특정 작업을 수행
                                onTap: () {
                                  if (controller.indicatorCount == 0) { /* 알 별 현재 출력 페이지 인디케이터 체크 변수가 0일 때 */
                                    return;
                                  }
                                  controller.setIsPageViewClick();
                                  pageController.previousPage( /// PageController.previousPage : 현재 페이지에서 이전 페이지로 애니메이션을 통해 전환
                                      duration: Duration(milliseconds: 500), /// 페이지 전환 애니메이션의 지속 시간
                                      curve: Curves.linear); /// 애니메이션의 곡선
                                },
                                child: Opacity( /// Opacity : Flutter에서 위젯의 투명도를 조절하는 데 사용되는 위젯. 0.0 : 완전 투명. 1.0 : 완전 불투명
                                  opacity: controller.isPageViewClick /* 페이지 뷰 이동 했을 경우 */ /// opacity : 위젯의 투명도 수준을 설정
                                      ? 0
                                      : controller.indicatorCount == 0
                                          ? 0.5
                                          : 1,
                                  child: Container(
                                    decoration: BoxDecoration( /// BoxDecoration : Container 위젯에 다양한 시각적 효과를 적용하기 위해 사용되는 클래스입니다. 이 클래스를 사용하면 배경색, 테두리, 그림자, 경계 반경 등 다양한 속성을 설정
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 2,
                                            color: HexColor('555D42'))),
                                    child: Container(
                                      child: CircleAvatar( /// CircleAvatar : Flutter에서 원형 프로필 사진이나 아이콘을 표시하는 데 사용되는 위젯
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
                child: EmotionBubble(), /* 마리모의 현재 상태[나쁨/보통/좋음]에 따라 말풍선으로 감정표현을 나타냄. */
              ),
            ],
          ),
        ));
  }
}

// 건강도 및 gop/gog 잠금 위젯과 깨우기/포기하기 버튼
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
                child: index == 0 || /* 보통알 일 경우 */
                        controller.isPlaying || /* 부화한 상태 */
                        (index == 1 && getx.gop.value > 0) || /* 특별한알 구입 ?? */
                        (index == 2 && getx.gog.value > 0) /* 프리미엄알 구입 ?? */
                    ? HealthBubble() /* 마리모의 건강도 숫자와 게이지 위젯 */
                    : OnlyGopOrGogText(index: index), /* gop/gog 전용 아닐 경우 잠금 위젯 */
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
              // 잠 깨우기/포기하기 버튼
              Expanded(
                child: ButtonGGnz(
                  buttonText: controller.isPlaying
                      ? '포기하기'
                      : controller.isIncubatorDone /* 파츠 성장 완료 상태 */
                          ? 'growth_complete'.tr /* 'growth_complete': '성장완료' */
                          : 'wake_up'.tr, /* 'wake_up': '잠 깨우기' */
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
                    if (controller.isIncubatorDone) { /* 파츠 성장 완료 상태 => '성장완료' 버튼 클릭 */
                      audioController.openAudioPlayer(
                          url: 'assets/sound/click_menu.mp3');
                      Get.dialog(const DispatchDialog(),
                          transitionCurve: Curves.decelerate,
                          transitionDuration: const Duration(milliseconds: 500));
                      return;
                    }

                    if (!controller
                        .indicatorCountState[controller.indicatorCount]!) { /* !알 별 페이지 버튼 활성화 체크 변수[알 별 현재 출력 페이지 인디케이터 체크 변수] => 알 존재하지 않을 경우 */
                      audioController.openAudioPlayer(
                          url: 'assets/sound/click_menu.mp3');
                      Get.dialog(GoToMarketDialog()); /* 알이 없는 경우에서 잠 깨우기 버튼을 클릭할 경우 '깨울 알이 없습니다. 상점으로 이동하시겠습니까?' 확인 다이어로그 */
                      return;
                    }

                    if (!controller.isPlaying) { /* 부화되지 않은 상태 */
                      controller.checkStartingServer();
                    }

                    if (controller.isPlaying) { /* 부화된 상태 */
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
