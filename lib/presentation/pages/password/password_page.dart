import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/login/login_controller.dart';
import 'package:ggnz/presentation/pages/password/password_page_controller.dart';
import 'package:hexcolor/hexcolor.dart';

/* 비밀번호 입력을 위한 키패드와 비밀번호 설정 및 확인 가능 기능 제공. */

// 비밀번호 입력 페이지. 기존 지갑이 있는 경우와 새로운 지갑을 만드는 경우로 구분되어 있다.
class PasswordPage extends StatelessWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasWallet = Get.arguments == null ? false : true; /* 지갑 기존/새로운 확인 */
    final controller = Get.put(PasswordPageController());
    return Scaffold(
      appBar: hasWallet /* 지갑이 없을 경우 */
          ? AppBar(
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    LoginController.instance.signOut();
                  },
                  icon: Icon(Icons.logout),
                )
              ],
          )
          : AppBar(
              elevation: 0,
              leading: InkWell(
                  onTap: () => Get.back(),
                  child: const Center(
                      child: Icon(Icons.arrow_back_ios, color: Colors.black))),
              backgroundColor: HexColor('#EAFAD9'),
              actions: [
                IconButton(
                    onPressed: () {
                      LoginController.instance.signOut();
                    },
                    icon: Icon(Icons.logout),
                )
              ],
            ),
      body: Container( /* 지갑이 있을 경우 */
          color: HexColor('#EAFAD9'),
          child: Obx(
            () => Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Spacer(flex: 1),
                  SizedBox(
                    width: Get.width * 0.8,
                    child: Text(
                      controller.isUserIdExist? "password_text2".tr: /* 'password_text2': '비밀번호 6자리를 입력해 주세요' */
                      controller.isFirstPasswordDone /* 1차 비밀번호 검증 */
                          ? 'confirm_password_text1'.tr /* 통과. ''confirm_password_text1': '한 번 더 입력해 주세요.' */
                          : 'password_text1'.tr, /* 1차 비밀번호에서 잘못 입력할 경우. 'password_text1': '비밀번호 6자리를 설정해 주세요'. */
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
                    /// 키패드로 입력한 비밀번호를 특정 단어로 대체
                      controller.isConfirmPassWord /* 6자리인지 확인 */
                          ? controller.confirmPassWord /* 6자리 일 경우 패스워드 확인 */
                              .replaceAll(RegExp('[0-9]'), "●")
                          : controller.passWord /* 6자리 이하 일 경우 현재 패스워드 입력 */
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

// 비밀번호 입력을 위한 키패드. 사용자가 숫자를 입력하면 비밀번호가 설정된다.
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
  final dynamic value; /* 키패드 키의 값으로, 키를 클릭할 때 전달되는 데이터. */
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
          if (Get.isSnackbarOpen) { /* 스낵바(Snackbar)가 열려 있는지를 확인 */
            return;
          }
          if (!controller.isClicked) {
            Get.snackbar('password'.tr, 'password_notice_check'.tr, /* 'password': '비밀번호', 'password_notice_check': '아래 체크 박스를 읽고 체크해주세요' */
                duration: Duration(seconds: 1));
            return;
          }
          controller.setKeyPadNums(value);
          if (controller.isConfirmPassWord) { /* 6자리 확인 */
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

// 비밀번호 설정 주의 사항 읽고 체크해야 패스워드 입력 가능.
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
                  value: controller.isClicked, /* 체크박스 체크 여부 확인 */
                  onChanged: (value) => controller.setIsClicked = value!)) /* 체크 안될 경우 값 입력 안됨. */
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'password_notice'.tr, /* 'password_notice': '비밀번호는 서버에 저장되지 않습니다. 비밀번호를 잃어버릴 시 복구가 불가하니 주의해 주세요.' */
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
