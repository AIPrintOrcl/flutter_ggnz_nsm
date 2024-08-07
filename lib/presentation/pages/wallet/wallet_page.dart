import 'dart:io';

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
                  // 현재 소지하고 있는 bait 정보
                  Image.asset("assets/coin/bait.png", width: 25),
                  const SizedBox(width: 8),
                  Text(
                    getx.bait.value < 1000 // bait가 천 단위 넘을 경우 format
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
                  Container( // 지갑 주소 확인 및 클립보드 복사
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
                    child: ButtonGGnz( // 지갑 주소를 클립보드 복사
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
              ...getx.uid.value != '' ? [] : [ // 유저 로그인 여부 확인 ? 소셜 login X : 소셜 login O
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
                            // 플랫폼에 따른 clientId = Platform.isAndroid ? android : ios
                            var clientId = Platform.isAndroid ? '441031740963-tf4oq8iknnu2u38lfbamdsblfs0d0eic.apps.googleusercontent.com' : '441031740963-huhdd8hiqf1c8lidj8cbc1hvgvrlllgo.apps.googleusercontent.com';
                            return SignInScreen(
                              providers: [
                                GoogleProvider(clientId: clientId),
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
                            // 현재 소지하고 있는 bait 정보 중복??
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
                    //const SizedBox(height: 30),
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

// 소셜 로그인 후 나타나는 화면을 확인하고 사용자 정보를 로컬에 저장하고 데이터베이스를 업데이트
class noneWidget extends StatelessWidget {
  const noneWidget({Key? key}) : super(key: key);

  // 소셜 로그인한 사용자 정보를 로컬에 저장하고 데이터베이스를 업데이트
  Future<bool> setLogin() async {
    // 로컬에  uid 저장
    getx.sharedPrefs.setString('uid', FirebaseAuth.instance.currentUser?.uid.toString() ?? '');
    getx.uid.value = FirebaseAuth.instance.currentUser?.uid.toString() ?? '';
    // 데이터베이스 업데이트
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
                      'social_login'.tr, // 'social_login': '소셜 로그인이 되었습니다.'
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
                          Get.back(); // 게임 메인 화면 ??
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}