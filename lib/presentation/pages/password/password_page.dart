import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/main_page.dart';
import 'package:ggnz/presentation/pages/password/password_page_controller.dart';
import 'package:ggnz/services/service_app_init.dart';
import 'package:hexcolor/hexcolor.dart';

class PasswordPage extends StatelessWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasWallet = Get.arguments == null ? false : true;
    final controller = Get.put(PasswordPageController());
    return Scaffold(
      appBar: hasWallet
          ? AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await controller.logOut();

              // Get.offAll(MainPage());
              Get.offAll(() => MainPage());
            },
          ),
        ],
        backgroundColor: HexColor('#EAFAD9'),
      )
          : AppBar(
        elevation: 0,
        leading: InkWell(
            onTap: () => Get.back(),
            child: const Center(
                child: Icon(Icons.arrow_back_ios, color: Colors.black))),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await controller.logOut();

              // Get.offAll(MainPage());
              Get.offAll(() => MainPage());
            },
          ),
        ],
        backgroundColor: HexColor('#EAFAD9'),
      ),
      body: Container(
          color: HexColor('#EAFAD9'),
          child: Obx(
                () => Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Spacer(flex: 1),
                  SizedBox(
                    width: Get.width * 0.8,
                    child: Text(
                      controller.isUserIdExist? "password_text2".tr: // 사용자 ID가 존재 할때 'password_text2': '비밀번호 6자리를 입력해 주세요'
                      controller.isFirstPasswordDone // 1/2차 비밀번호
                          ? 'confirm_password_text1'.tr // 'confirm_password_text1': '한 번 더 입력해 주세요.' =? 지갑 비밀번호 생성 시 2차 비밀번호 입력
                          : 'password_text1'.tr, // 'password_text1': '비밀번호 6자리를 설정해 주세요'. => 지갑 비밀번호 생성 시 1차 비밀번호 입력
                      style: TextStyle(
                          fontSize: 26,
                          color: HexColor('#555D42'),
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          fontWeight: FontWeight.w400,
                          height: 1.45),
                      textAlign: TextAlign.center,
                      textWidthBasis: TextWidthBasis.parent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Spacer(flex: 1),
                  Text(
                    // 키패드로 입력한 비밀번호를 특정 단어로 대체
                      controller.isConfirmPassWord // 2차 비밀번호 입력일 경우
                          ? controller.confirmPassWord // 6자리 일 경우 패스워드 확인
                          .replaceAll(RegExp('[0-9]'), "●")
                          : controller.passWord // 6자리 이하 일 경우 현재 패스워드 입력
                          .replaceAll(RegExp('[0-9]'), "●"),
                      style: TextStyle(
                          letterSpacing: 10,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: HexColor("#D9D9D9"))),
                  const Spacer(flex: 1),
                  const KeyPad(),
                  const Spacer(flex: 1),
                  const PasswordInfo()
                ]),
          )),
    );
  }
}

class KeyPad extends StatelessWidget {
  const KeyPad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordPageController>();
    return Obx(() => Column(
      children: [
        ...controller.keyPadNums
            .map((x) => SizedBox(
          height: 70,
          child: Row(
            children: x
                .map((y) => Expanded(
                child:
                KeyPadKey(label: y.toString(), value: y)))
                .toList(),
          ),
        ))
            .toList(),
      ],
    ));
  }
}

class KeyPadKey extends StatelessWidget {
  final String label;
  final dynamic value;
  const KeyPadKey({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordPageController>();
    return InkWell(
        onTap: () {
          if (Get.isSnackbarOpen) {
            return;
          }
          if (!controller.isClicked) {
            Get.snackbar('password'.tr, 'password_notice_check'.tr,
                duration: Duration(seconds: 1));
            return;
          }
          controller.setKeyPadNums(value);
          if (controller.isConfirmPassWord) {
            controller.setConfirmPassWord(value);
          } else {
            controller.setPassWord(value);
          }
        },
        child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontFamily: 'ONE_Mobile_POP_OTF',
              ),
            )));
  }
}

class PasswordInfo extends StatelessWidget {
  const PasswordInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordPageController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: HexColor('#555D42'),
      height: 74,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Checkbox(
                  value: controller.isClicked,
                  onChanged: (value) => controller.setIsClicked = value!))
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'password_notice'.tr,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
