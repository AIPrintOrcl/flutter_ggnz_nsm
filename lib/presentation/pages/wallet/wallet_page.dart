import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' ;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/utility_function.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:intl/intl.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletPageController = Get.find<WalletPageController>();
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(
        url: 'assets/sound/click_menu_open_close.mp3');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: HexColor('EAFAD9'),
        title: Text('wallet'.tr,
            style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        centerTitle: true,
        leading: InkWell(
            onTap: () => Get.back(),
            child: const Center(
                child: Icon(Icons.arrow_back_ios, color: Colors.black))),
      ),
      body: Obx(
        () => Container(
          width: Get.width,
          height: Get.height,
          padding: const EdgeInsets.fromLTRB(20, 45, 20, 0),
          color: HexColor('EAFAD9'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/coin/bait.png", width: 25),
                  const SizedBox(width: 8),
                  Text(
                    getx.bait.value < 1000
                        ? getx.bait.value.toInt().toString()
                        : NumberFormat.compactCurrency(
                            decimalDigits: 2,
                            locale: 'en_EN',
                            symbol: '',
                          ).format(getx.bait.value.toInt()),
                    style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: HexColor('6D7B76')),
                  )
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(21, 15, 21, 15),
                      decoration: BoxDecoration(
                          color: HexColor('#F4FBEE'),
                          border:
                              Border.all(width: 2, color: HexColor('#6D7B76')),
                          borderRadius: BorderRadius.circular(100)),
                      child: GestureDetector(
                        onTap: () {
                          walletPageController.copyClipBorad(getx.walletAddress.value);
                        },
                        child: Text(
                            getx.walletAddress.value.substring(0, 15) + "...",
                            style: TextStyle(
                              fontFamily: 'ONE_Mobile_POP_OTF',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: HexColor('#818181'),
                            )),
                      ))
                ],
              ),
              const SizedBox(height: 31),
              Row(
                children: [
                  Expanded(
                    child: ButtonGGnz(
                      width: Get.width,
                      buttonText: 'COPY USER ID',
                      buttonBorderColor: HexColor("#555D42"),
                      buttonColor: HexColor("#DAEAD4"),
                      isBoxShadow: true,
                      style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        color: HexColor("#555D42"),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      onPressed: () async {
                        audioController.openAudioPlayer(url: 'assets/sound/click_menu.mp3');
                        /*final result = await Get.to(
                                () => SignWalletPage(
                              signReason: 'private_key_export'.tr,
                            ),
                            arguments: {
                              "reason": 'private_key_export',
                            });*/
                        walletPageController.copyClipBorad(getx.walletAddress.value);
                      },
                    ),
                  ),
                  /*const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: ButtonGGnz(
                      buttonText: 'exchange'.tr,
                      buttonBorderColor: HexColor("#555D42"),
                      buttonColor: HexColor("#DAEAD4"),
                      isBoxShadow: true,
                      style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        color: HexColor("#555D42"),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      onPressed: () {
                        audioController.openAudioPlayer(
                            url: 'assets/sound/click_menu.mp3');
                        Get.to(() => const WalletExchangePage(),
                            transition: Transition.fadeIn,
                            arguments: {"from": "BAIT", "to": "GGNZ"},
                            duration: const Duration(milliseconds: 500));
                      },
                    ),
                  ),*/
                ],
              ),
              /*const SizedBox(height: 31),
              // 소셜 login
              SignInScreen(
                providers: [
                  GoogleProvider(clientId: '441031740963-97of9d709oheps0dmfl8ovuvdmimg1lo.apps.googleusercontent.com')
                ],
              ),*/
              ...getx.uid.value != '' ? [] : [
                const SizedBox(height: 16),
                ButtonGGnz(
                  width: Get.width,
                  buttonText: 'SOCIAL LOGIN',
                  buttonBorderColor: HexColor("#555D42"),
                  buttonColor: HexColor("#DAEAD4"),
                  isBoxShadow: true,
                  style: TextStyle(
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    color: HexColor("#555D42"),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  onPressed: () async {
                    audioController.openAudioPlayer(url: 'assets/sound/click_menu.mp3');

                    Get.to(() => StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SignInScreen(
                              providers: [
                                GoogleProvider(clientId: '441031740963-97of9d709oheps0dmfl8ovuvdmimg1lo.apps.googleusercontent.com'),
                                AppleProvider()
                              ],
                            );
                          }

                          return noneWidget();
                        }
                    )
                    );
                  },
                )
              ],
              const SizedBox(height: 31),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                decoration: BoxDecoration(
                    color: HexColor('#F4FBEE'),
                    border: Border.all(width: 5, color: HexColor('#6D7B76')),
                    borderRadius: BorderRadius.circular(25)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset("assets/coin/bait.png", width: 25),
                            const SizedBox(width: 8),
                            Text(
                              'BAIT',
                              style: TextStyle(
                                  fontFamily: 'ONE_Mobile_POP_OTF',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: HexColor('#555D42')),
                            ),
                          ],
                        ),
                        Text(
                          getx.bait.value < 1000
                              ? getx.bait.value.toInt().toString()
                              : NumberFormat.compactCurrency(
                                  decimalDigits: 2,
                                  locale: 'en_EN',
                                  symbol: '',
                                ).format(getx.bait.value.toInt()),
                          style: TextStyle(
                              fontFamily: 'ONE_Mobile_POP_OTF',
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        )
                      ],
                    ),
                    // const SizedBox(height: 30),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset("assets/coin/ggnz.png", width: 25),
                            const SizedBox(width: 8),
                            Text(
                              'GGNZ',
                              style: TextStyle(
                                  fontFamily: 'ONE_Mobile_POP_OTF',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: HexColor('#555D42')),
                            ),
                          ],
                        ),
                        Text(
                          NumberFormat.compactCurrency(
                            decimalDigits: 2,
                            locale: 'en_EN',
                            symbol: '',
                          ).format(getx.ggnz.value),
                          style: TextStyle(
                              fontFamily: 'ONE_Mobile_POP_OTF',
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        )
                      ],
                    ),*/
                    //const SizedBox(height: 30),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset("assets/coin/klay.png", width: 25),
                            const SizedBox(width: 8),
                            Text(
                              'KLAY',
                              style: TextStyle(
                                  fontFamily: 'ONE_Mobile_POP_OTF',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: HexColor('#555D42')),
                            ),
                          ],
                        ),
                        Text(
                          NumberFormat.compactCurrency(
                            decimalDigits: 2,
                            locale: 'en_EN',
                            symbol: '',
                          ).format(getx.klay.value),
                          style: TextStyle(
                              fontFamily: 'ONE_Mobile_POP_OTF',
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        )
                      ],
                    ),*/
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class noneWidget extends StatelessWidget {
  const noneWidget({Key? key}) : super(key: key);

  Future<bool> setLogin() async {
    getx.sharedPrefs.setString('uid', FirebaseAuth.instance.currentUser?.uid.toString() ?? '');
    getx.uid.value = FirebaseAuth.instance.currentUser?.uid.toString() ?? '';
    await updateUserDB(getx.db, {
      'uid': FirebaseAuth.instance.currentUser?.uid.toString(),
      'email': FirebaseAuth.instance.currentUser?.email.toString()
    }, false);

    return false;
  }

  @override
  Widget build(BuildContext context) {
    setLogin();
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
                      'social_login'.tr,
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
                        buttonText: 'Go Home',
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
                          Get.back();
                          Get.back();
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );;
  }
}
