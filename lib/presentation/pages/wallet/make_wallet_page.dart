import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/pages/password/password_page.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ggnz/services/service_functions.dart';

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
                        'create_a_olchaeneez_wallet'.tr,
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
                        'craete_olchaeneez_wallet_text'.tr,
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
                    Row(
                      children: [
                        ButtonGGnz(
                            buttonText: 'create_a_wallet'.tr,
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
                              Get.to(() => const PasswordPage(),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500));
                            }),
                        const SizedBox(
                          width: 10,
                        ),
                        ButtonGGnz(
                            buttonText: 'IMPORT',
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
                              Get.to(() => const ImportPage(),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500));
                            })
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
            'add_account'.tr,
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
                'add_account_text'.tr,
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
              TextFormField(
                controller: importTextController,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: 'private_key'.tr,
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
                    if (importTextController.text.length == 64
                        || importTextController.text.length == 66
                        && importTextController.text.substring(0, 2) == "0x"
                    ) {
                      Get.back();
                      Get.to(() => const PasswordPage(),
                          arguments: {"key": importTextController.text},
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 500));

                    } else {
                      showSnackBar("개인키를 확인해주세요.");
                    }
                  }),
            ],
          ),
        ));
  }
}
