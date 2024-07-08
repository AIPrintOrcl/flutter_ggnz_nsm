import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_page.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class ButtonCoins extends StatelessWidget {
  final double coinAmount;
  final String imageUrl;
  final bool isInt;
  const ButtonCoins(
      {Key? key,
      required this.coinAmount,
      required this.imageUrl,
      required this.isInt})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 2,
      locale: 'en_EN',
      symbol: '',
    ).format(coinAmount);
    return GestureDetector(
      onTap: () {
        final audioController = Get.find<AudioController>();
        audioController.openAudioPlayer(
            url: 'assets/sound/click_menu_open_close.mp3');
        Get.to(() => const WalletPage(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
      },
      child: Container(
        width: 75,
        height: 24,
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
        decoration: BoxDecoration(
            color: HexColor('#DAEAD4'),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(width: 1, color: HexColor('#555D42'))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
                radius: 10,
                child: Image.asset(
                  imageUrl,
                )),
            Expanded(
              child: Text(
                isInt && coinAmount < 1000? coinAmount.toInt().toString(): _formattedNumber,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
