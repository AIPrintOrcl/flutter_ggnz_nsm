import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/wallet/sign_wallet_page.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/widgets/watch.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class DispatchDialog extends StatelessWidget {
  const DispatchDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncubatorPageController>();
    final audioController = Get.find<AudioController>();

    return Obx(
          () => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/notice_paper.png',
                    fit: BoxFit.cover,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 35,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: Duration(seconds: 1),
                            switchInCurve: Curves.linear,
                            child: controller.isDispatch
                                ? Container(
                              key: Key('start'),
                              width: Get.width / 3.5,
                              height: Get.width / 3.5,
                              child: ClipRRect( /// ClipRRect : 둥근 모서리를 가진 컨테이너를 만들거나 이미지, 카드 등의 위젯에 모서리를 둥글게 처리
                                borderRadius: BorderRadius.circular(15), /// borderRadius : 모서리를 둥글게 할 반경을 설정
                                child: Image.asset(
                                    'assets/dispatch_ani.gif', /* 로켓이 우주로 가는 애니메이션 gif */
                                    width: Get.width / 3.5),
                              ),
                            )
                                : Container(
                              key: Key('stop'),
                              width: Get.width / 3.5,
                              height: Get.width / 3.5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                    'assets/dispatch.png', /* 로켓 이미지 */
                                    width: Get.width / 3.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          DispatchInfo(),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonGGnz(
                          width: 179,
                          buttonText: 'dispatch'.tr, /* 'dispatch': '방생하기' */
                          buttonBorderColor: HexColor("#555D42"),
                          buttonColor: HexColor("#DAEAD4"),
                          style: TextStyle(
                            fontFamily: 'ONE_Mobile_POP_OTF',
                            color: HexColor("#555D42"),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          isBoxShadow: true,
                          onPressed: (() async {
                            Get.back();
                            final result = await Get.to(
                                    () => SignWalletPage(
                                  signReason: 'dispatch_start'.tr, /* 'dispatch_start': '올채니를 방생하시겠습니까?' */
                                ),
                                arguments: {
                                  "reason": 'dispatch_start',
                                  "amount":
                                  (getx.healthLevel.value.toInt() ~/ 10) /* 건강도 레벨 값/10 */
                                });
                          })),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Divider(
                          height: Get.height / 12,
                          thickness: 2,
                        ),
                      ),
                      controller.isAbleMint ? MintInfo() : DisableMintInfo(),
                    ],
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}

class CreditTransitionPage extends StatefulWidget {
  CreditTransitionPage({Key? key}) : super(key: key);

  @override
  State<CreditTransitionPage> createState() => _CreditTransitionPageState();
}

class _CreditTransitionPageState extends State<CreditTransitionPage> {
  final audioController = Get.find<AudioController>();
  final incubatorPageController = Get.find<IncubatorPageController>();

  @override
  void initState() {
    audioController.openAudioPlayer(url: 'assets/sound/credit_sound.mp3');
    Future.delayed(Duration(seconds: 15), () {
      audioController.openAudioPlayer(
          url: 'assets/sound/dispatch_get_money.mp3');
    });

    moveToNextPage();
    super.initState();
  }

  @override
  void dispose() {
    imageCache.clear();
    super.dispose();
  }

  void moveToNextPage() {
    Future.delayed(Duration(seconds: 16), (() {
      Get.back(result: true);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/credit_ani.gif',
                ),
                fit: BoxFit.cover)),
      ),
    );
  }
}

class DispatchInfo extends StatelessWidget {
  DispatchInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int earnedBait = (getx.healthLevel.value.toInt() ~/ 10);

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/mint_bubble.png',
          width: Get.width / 3.1,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: HexColor("#555D42"),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              child: Text(
                'reward_for_dispatch'.tr,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Image.asset(
                  'assets/coin/bait.png',
                  width: 18,
                ),
                const SizedBox(
                  width: 4,
                ),
                DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    color: Colors.green.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  child: Text(
                    '$earnedBait',
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: HexColor("#555D42"),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              child: Text(
                'energy_saving_time'.tr,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Watch(
              isDialog: true,
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ],
    );
  }
}

class MintInfo extends StatelessWidget {
  MintInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncubatorPageController>();
    final audioController = Get.find<AudioController>();
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Container(
              key: Key('start'),
              width: Get.width / 3.5,
              height: Get.width / 3.5,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child:
                      Image.asset('assets/mint.png', width: Get.width / 3.5)),
            ),
            const SizedBox(width: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/mint_bubble.png',
                  width: Get.width / 3.1,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: Get.width / 4,
                      child: DefaultTextStyle(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: HexColor("#555D42"),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        child: Text(
                          'give_up_dispatch'.tr,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: Get.width / 4,
                      child: DefaultTextStyle(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: HexColor("#555D42"),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        child: Text(
                          'need_some_tokens'.tr,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer()
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ButtonGGnz(
            width: 179,
            buttonText: 'adopt'.tr,
            buttonBorderColor: HexColor("#555D42"),
            buttonColor: HexColor("#DAEAD4"),
            style: TextStyle(
              fontFamily: 'ONE_Mobile_POP_OTF',
              color: HexColor("#555D42"),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            isBoxShadow: true,
            onPressed: (() async {
              Get.dialog(
                AlertDialog(
                  title: Text(
                    '1000 GGNZ or ${'OCNZ Mint'.tr}',
                    style: TextStyle(
                      fontFamily: 'ONE_Mobile_POP_OTF',
                      color: HexColor("#555D42"),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  content: Text(
                    '무엇을 사용하여 입양을 하시겠습니까?',
                    style: TextStyle(
                      fontFamily: 'ONE_Mobile_POP_OTF',
                      color: HexColor("#555D42"),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  actions: [
                    ButtonGGnz(
                        width: 179,
                        buttonText: "1000 GGNZ",
                        buttonBorderColor: HexColor("#555D42"),
                        buttonColor: HexColor("#DAEAD4"),
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: HexColor("#555D42"),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        onPressed: () async {
                          // 1000 ggnz minting
                          Get.back();
                          Get.back();
                          final result = await Get.to(
                              () => SignWalletPage(
                                    signReason: 'OCNZ Mint Description'.tr,
                                  ),
                              arguments: {
                                "reason": 'MINT',
                                "type": 1,
                                "amount": (getx.healthLevel.value.toInt() ~/ 10)
                              });
                        },
                        isBoxShadow: false),
                    const SizedBox(
                      height: 20,
                    ),
                    ButtonGGnz(
                        width: 179,
                        buttonText: '${'OCNZ Mint'.tr}',
                        buttonBorderColor: HexColor("#555D42"),
                        buttonColor: HexColor("#DAEAD4"),
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: HexColor("#555D42"),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        onPressed: () async {
                          if (getx.items["OCNZ Mint"]!["amount"] > 0) {
                            // 민팅권 사용해서 입양할 때
                            Get.back();
                            Get.back();
                            final result = await Get.to(
                                () => SignWalletPage(
                                      signReason: 'OCNZ Mint Description'.tr,
                                    ),
                                arguments: {
                                  "reason": 'MINT',
                                  "type": 2,
                                  "amount":
                                      (getx.healthLevel.value.toInt() ~/ 10)
                                });
                          } else {
                            Get.snackbar('${Get.arguments}', '',
                                padding:
                                    const EdgeInsets.fromLTRB(10, 30, 10, 10),
                                backgroundColor:
                                    HexColor('#2E0C0C').withOpacity(0.7),
                                duration: const Duration(seconds: 2),
                                titleText: Center(
                                    child: Text('not_enough_items'.tr,
                                        style: TextStyle(
                                          fontFamily: 'ONE_Mobile_POP_OTF',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ))));
                          }
                        },
                        isBoxShadow: false),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                  actionsAlignment: MainAxisAlignment.center,
                ),
              );
              // final result = await Get.to(
              //     () => const SignWalletPage(
              //           signReason: 'MINT',
              //         ),
              //     arguments: {"reason": 'MINT'},
              //     duration: Duration(milliseconds: 500),
              //     transition: Transition.fadeIn);

              // if (result) {
              //   audioController.openAudioPlayer(
              //       url: 'assets/sound/click_menu.mp3');
              //   controller.minting();
              //   Get.back();
              // }
            })),
        const SizedBox(
          height: 35,
        ),
      ],
    );
  }
}

class DisableMintInfo extends StatelessWidget {
  DisableMintInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                const Spacer(),
                Container(
                  key: Key('start'),
                  width: Get.width / 3.5,
                  height: Get.width / 3.5,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                          child: Image.asset('assets/mint.png',
                              width: Get.width / 3.5))),
                ),
                const SizedBox(width: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/mint_bubble.png',
                      width: Get.width / 3.1,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: Get.width / 4,
                          child: DefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ONE_Mobile_POP_OTF',
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            child: Text(
                              'give_up_dispatch'.tr,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: Get.width / 4,
                          child: DefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ONE_Mobile_POP_OTF',
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            child: Text(
                              'need_some_tokens'.tr,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer()
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ButtonGGnz(
                width: 179,
                buttonText: "MINT",
                buttonBorderColor: Colors.grey,
                buttonColor: Colors.grey.shade300,
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  color: Colors.grey.shade300,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                isBoxShadow: true,
                onPressed: (() {})),
            const SizedBox(
              height: 35,
            ),
          ],
        ),
        Transform.rotate(
          angle: -0.5,
          child: Center(
            child: Image.asset(
              'assets/mint_lock.png',
              width: Get.width / 2.5,
            ),
          ),
        )
      ],
    );
  }
}
