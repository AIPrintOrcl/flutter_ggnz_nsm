import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/login/login_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:hexcolor/hexcolor.dart';

class LoginPage extends StatelessWidget {

  LoginPage({super.key});

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
                        'Login',
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
                    Row(
                      children: [
                        ButtonGGnz(
                            buttonText: 'Google Loing', /* 구글 로그인 버튼 */
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
                              /// 구글 로그인
                              LoginController.instance.signInWithGoogle();
                            }),
                        const SizedBox(
                          width: 10,
                        ),
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
