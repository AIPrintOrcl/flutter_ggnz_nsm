import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/wallet/sign_wallet_page.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_exchange_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_exchange.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:intl/intl.dart';
import 'package:ggnz/utils/audio_controller.dart';

class WalletExchangePage extends StatelessWidget {
  const WalletExchangePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(WalletExchangeController());
    final Map<String, String> arg = Get.arguments;
    final audioController = Get.find<AudioController>();
    final walletExchangeController = Get.find<WalletExchangeController>();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: HexColor('EAFAD9'),
          leading: InkWell(
              onTap: () => Get.back(),
              child: const Center(
                  child: Icon(Icons.arrow_back_ios, color: Colors.black))),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            width: Get.width,
            height: Get.height,
            padding: const EdgeInsets.fromLTRB(20, 45, 20, 0),
            color: HexColor('EAFAD9'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExchangeFromBox(from: arg["from"]!),
                const SizedBox(
                  height: 15,
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(width: 3, color: HexColor('555D42'))),
                    child: const Center(
                      child: Icon(Icons.arrow_downward),
                    )),
                const SizedBox(
                  height: 15,
                ),
                ExchangeToBox(to: arg["to"]!),
                Expanded(
                    child: ButtonGGnz(
                        buttonText: "exchange".tr,
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
                          Get.back();
                          var selectedAmount =
                              walletExchangeController.selectedFromCoin ==
                                      "BAIT"
                                  ? walletExchangeController.baitAmount.value
                                  : walletExchangeController.ggnzAmount.value;
                          Get.to(
                              () => SignWalletPage(
                                  signReason: 'exchange_coin'.tr),
                              arguments: {
                                "reason": 'exchange_coin',
                                "amount": selectedAmount,
                                "from":
                                    walletExchangeController.selectedFromCoin,
                                "to": walletExchangeController.selectedToCoin
                              });
                        }))
              ],
            ),
          ),
        ));
  }
}

class ExchangeFromBox extends StatelessWidget {
  const ExchangeFromBox({Key? key, required this.from}) : super(key: key);
  final String from;

  @override
  Widget build(BuildContext context) {
    final walletExchangeController = Get.find<WalletExchangeController>();
    walletExchangeController.setSelectedFromCoin = from;
    return Obx(() => Container(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          decoration: BoxDecoration(
              color: HexColor('#F4FBEE'),
              border: Border.all(width: 5, color: HexColor('#6D7B76')),
              borderRadius: BorderRadius.circular(25)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'From',
                    style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // from == "BAIT"?
                  SizedBox(
                    width: 100.0,
                    height: 50.0,
                    child: TextField(
                      controller: TextEditingController(text: "0"),
                      onChanged: (text) {
                        if (text == '') {
                          return;
                        }
                        if (walletExchangeController.selectedFromCoin ==
                            'BAIT') {
                          walletExchangeController.baitAmount.value =
                              int.parse(text);
                        } else {
                          walletExchangeController.ggnzAmount.value =
                              int.parse(text);
                        }
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  )
                  // :
                  // Text(
                  //   (getx.baitPrice * walletExchangeController.baitAmount.value).toString(),
                  //   style: TextStyle(
                  //       fontFamily: 'ONE_Mobile_POP_OTF',
                  //       fontSize: 40,
                  //       fontWeight: FontWeight.w700,
                  //       color: Colors.black),
                  // )
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                            fontFamily: 'ONE_Mobile_POP_OTF',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: HexColor('#515151')),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        walletExchangeController.selectedFromCoin == "BAIT"
                            ? getx.bait.value < 1000
                                ? getx.bait.value.toInt().toString()
                                : NumberFormat.compactCurrency(
                                    decimalDigits: 2,
                                    locale: 'en_EN',
                                    symbol: '',
                                  ).format(getx.bait.value.toInt())
                            : NumberFormat.compactCurrency(
                                decimalDigits: 2,
                                locale: 'en_EN',
                                symbol: '',
                              ).format(getx.ggnz.value),
                        style: TextStyle(
                            fontFamily: 'ONE_Mobile_POP_OTF',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      )
                    ],
                  ),
                  ExchangeButton(
                    isFrom: true,
                    coinImageUrl: walletExchangeController.exchangeCoinsMap[
                        walletExchangeController.selectedFromCoin],
                    coinName: walletExchangeController.selectedFromCoin,
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

class ExchangeToBox extends StatelessWidget {
  const ExchangeToBox({Key? key, required this.to}) : super(key: key);
  final String to;

  @override
  Widget build(BuildContext context) {
    final walletExchangeController = Get.find<WalletExchangeController>();
    walletExchangeController.setSelectedToCoin = to;
    print("test to: $to");
    return Obx(() => Container(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          decoration: BoxDecoration(
              color: HexColor('#F4FBEE'),
              border: Border.all(width: 5, color: HexColor('#6D7B76')),
              borderRadius: BorderRadius.circular(25)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'to',
                    style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // walletExchangeController.selectedToCoin == "BAIT"
                  //     ?

                  //     SizedBox(
                  //         width: 100.0,
                  //         height: 50.0,
                  //         child: TextField(
                  //           controller: TextEditingController(text: "0"),
                  //           onChanged: (text) {
                  //             try {
                  //               walletExchangeController.baitAmount.value =
                  //                   int.parse(text);
                  //             } catch (error) {}
                  //           },
                  //           keyboardType: TextInputType.number,
                  //           inputFormatters: <TextInputFormatter>[
                  //             FilteringTextInputFormatter.digitsOnly
                  //           ],
                  //           style: TextStyle(
                  //               fontFamily: 'ONE_Mobile_POP_OTF',
                  //               fontSize: 40,
                  //               fontWeight: FontWeight.w700,
                  //               color: Colors.black),
                  //         ),
                  //       )
                  //     :
                  Text(
                    (walletExchangeController.selectedToCoin == "GGNZ"
                            ? getx.baitPrice *
                                walletExchangeController.baitAmount.value
                            : walletExchangeController.ggnzAmount.value /
                                getx.baitPrice)
                        .toStringAsFixed(2),
                    style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
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
                      Text(
                        'Balance',
                        style: TextStyle(
                            fontFamily: 'ONE_Mobile_POP_OTF',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: HexColor('#515151')),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        walletExchangeController.selectedToCoin == "BAIT"
                            ? getx.bait.value < 1000
                                ? getx.bait.value.toInt().toString()
                                : NumberFormat.compactCurrency(
                                    decimalDigits: 2,
                                    locale: 'en_EN',
                                    symbol: '',
                                  ).format(getx.bait.value.toInt())
                            : NumberFormat.compactCurrency(
                                decimalDigits: 2,
                                locale: 'en_EN',
                                symbol: '',
                              ).format(getx.ggnz.value),
                        style: TextStyle(
                            fontFamily: 'ONE_Mobile_POP_OTF',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      )
                    ],
                  ),
                  ExchangeButton(
                    isFrom: false,
                    coinImageUrl: walletExchangeController.exchangeCoinsMap[
                        walletExchangeController.selectedToCoin],
                    coinName: walletExchangeController.selectedToCoin,
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
