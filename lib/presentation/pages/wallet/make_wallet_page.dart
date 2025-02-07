import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/pages/password/password_page.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';

// 사용자가 새로운 지갑을 생성하거나 기존 지갑을 가져올 수 있도록 안내하는 페이지.
class MakeWalletPage extends StatelessWidget {
  const MakeWalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  child: Image.asset('assets/notice_paper.png')),
              Positioned(
                top: 20,
                bottom: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        'create_a_olchaeneez_wallet'.tr, /* '올채니즈 지갑을 만들어 보세요!' */
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: HexColor('#555D42'),
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        'craete_olchaeneez_wallet_text'.tr, /* '올채니즈는 깨끗한 환경에서 건강하게 자라납니다. 휴대폰 배터리 사용을 줄일수록 연못의 환경이 더 좋아져요.  환경을 깨끗하게 하고 올채니즈를 건강하게 키워 더 많은 보상을 받으세요!' */
                        style: TextStyle(
                            fontFamily: 'ONE_Mobile_POP_OTF',
                            color: HexColor('#555D42'),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.8),
                        textAlign: TextAlign.center,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        ButtonGGnz(
                            buttonText: 'LOGIN',//'create_a_wallet'.tr,
                            width: Get.width / 2.7,
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
                              final audioController =
                              Get.find<AudioController>();
                              audioController.openAudioPlayer(
                                  url: 'assets/sound/click_menu.mp3');
                              /// 구글 로그인
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
                                    return const PasswordPage();
                                  }
                              )
                              );
                            }),
                        /*const SizedBox(
                          width: 10,
                        ),
                        ButtonGGnz(
                            buttonText: 'IMPORT UserId', *//* IMPORT 버튼 *//*
                            width: Get.width / 2.7,
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
                              Get.to(() => const ImportPage(), *//* 임폴트 페이지 이동 *//*
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500));
                            })*/
                      ],
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}

// 사용자가 개인 키를 입력하여 기존 지갑을 가져올 수 있도록 하는 페이지
class ImportPage extends StatelessWidget {
  const ImportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final importTextController = TextEditingController();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'add_account'.tr, /* =계정 추가 */
            style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black),
          ),
          centerTitle: true,
          leading: InkWell(
              onTap: () => Get.back(),
              child: const Center(
                  child: Icon(Icons.arrow_back_ios, color: Colors.black))),
          backgroundColor: HexColor('#EAFAD9'),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: HexColor('#EAFAD9'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'add_account_text'.tr, /* =가져올 계정의 개인키를 입력해주세요. */
                style: TextStyle(
                    height: 1.5,
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField( /* 개인키 입력 필드 */
                controller: importTextController,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: 'private_key'.tr, /* =개인키 */
                    labelStyle: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        fontSize: 20,
                        color: HexColor('#555D42')),
                    helperText: '',
                    hintText: '',
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: HexColor('#555D42'))),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: HexColor('#555D42'),
                    ))),
              ),
              ButtonGGnz(
                  buttonText: 'IMPORT',
                  width: 176,
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
                    final audioController = Get.find<AudioController>();
                    audioController.openAudioPlayer(
                        url: 'assets/sound/click_menu.mp3');
                    Get.back();
                    Get.to(() => const PasswordPage(),
                        arguments: {"key": importTextController.text},
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 500));
                  }),
            ],
          ),
        ));
  }
}
