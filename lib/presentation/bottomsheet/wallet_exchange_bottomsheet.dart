import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_exchange_page_controller.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class WalletExchangeBottomSheet extends StatelessWidget {
  final bool isFrom;
  const WalletExchangeBottomSheet({Key? key, required this.isFrom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final exchangeController = Get.find<WalletExchangeController>();
    final audioController = Get.find<AudioController>();
    final walletExchangeController = Get.find<WalletExchangeController>();
    return Container(
        height: 220,
        padding: const EdgeInsets.fromLTRB(25, 40, 25, 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: (() {
                if (!isFrom && exchangeController.selectedFromCoin == 'BAIT') {
                  return;
                }
                walletExchangeController.baitAmount.value = 0;
                walletExchangeController.ggnzAmount.value = 0;

                isFrom
                    ? exchangeController.setSelectedFromCoin = 'BAIT'
                    : exchangeController.setSelectedToCoin = 'BAIT';
                audioController.openAudioPlayer(
                    url: 'assets/sound/click_menu.mp3');
                Get.back();
              }),
              child: Opacity(
                opacity:
                    !isFrom && exchangeController.selectedFromCoin == 'BAIT'
                        ? 0.3
                        : 1,
                child: Row(
                  children: [
                    Image.asset("assets/coin/bait.png", width: 24),
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
              ),
            ),
            InkWell(
              onTap: (() {
                if (!isFrom && exchangeController.selectedFromCoin == 'GGNZ') {
                  return;
                }
                walletExchangeController.baitAmount.value = 0;
                walletExchangeController.ggnzAmount.value = 0;
                isFrom
                    ? exchangeController.setSelectedFromCoin = 'GGNZ'
                    : exchangeController.setSelectedToCoin = 'GGNZ';
                audioController.openAudioPlayer(
                    url: 'assets/sound/click_menu.mp3');
                Get.back();
              }),
              child: Opacity(
                opacity:
                    !isFrom && exchangeController.selectedFromCoin == 'GGNZ'
                        ? 0.3
                        : 1,
                child: Row(
                  children: [
                    Image.asset("assets/coin/ggnz.png", width: 24),
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
              ),
            ),
            // InkWell(
            //   onTap: (() {
            //     if (!isFrom && exchangeController.selectedFromCoin == 'KLAY') {
            //       return;
            //     }
            //     isFrom
            //         ? exchangeController.setSelectedFromCoin = 'KLAY'
            //         : exchangeController.setSelectedToCoin = 'KLAY';
            //     audioController.openAudioPlayer(
            //         url: 'assets/sound/click_menu.mp3');
            //     Get.back();
            //   }),
            //   child: Opacity(
            //     opacity:
            //         !isFrom && exchangeController.selectedFromCoin == 'KLAY'
            //             ? 0.3
            //             : 1,
            //     child: Row(
            //       children: [
            //         Image.asset("assets/coin/klay.png", width: 24),
            //         const SizedBox(width: 8),
            //         Text(
            //           'KLAY',
            //           style: TextStyle(
            //               fontFamily: 'ONE_Mobile_POP_OTF',
            //               fontSize: 22,
            //               fontWeight: FontWeight.w400,
            //               color: HexColor('#555D42')),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ));
  }
}
