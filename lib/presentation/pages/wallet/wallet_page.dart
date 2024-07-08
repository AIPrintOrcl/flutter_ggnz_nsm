import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_exchange_page.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:intl/intl.dart';
import 'package:ggnz/presentation/pages/wallet/sign_wallet_page.dart';
import 'package:ggnz/web3dart/crypto.dart';

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
              const SizedBox(height: 45),
              Row(
                children: [
                  Expanded(
                    child: ButtonGGnz(
                      buttonText: 'EXPORT',
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
                        final result = await Get.to(
                                () => SignWalletPage(
                              signReason: 'private_key_export'.tr,
                            ),
                            arguments: {
                              "reason": 'private_key_export',
                            });

                        if (result) {
                          walletPageController.copyClipBorad(bytesToHex(getx.credentials.privateKey));
                        }
                      },
                    ),
                  ),
                  const SizedBox(
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
                  ),
                ],
              ),
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
                    const SizedBox(height: 30),
                    Row(
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
                    ),
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
