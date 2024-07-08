import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/bottomsheet/wallet_exchange_bottomsheet.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class ExchangeButton extends StatelessWidget {
  final bool isFrom;
  final String coinImageUrl;
  final String coinName;
  const ExchangeButton(
      {Key? key,
      required this.isFrom,
      required this.coinImageUrl,
      required this.coinName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();
    return InkWell(
      onTap: () {
        if (!isFrom) {
          return;
        }
        audioController.openAudioPlayer(url: 'assets/sound/click_menu.mp3');
        Get.bottomSheet(WalletExchangeBottomSheet(isFrom: isFrom),
            backgroundColor: HexColor('EAFAD9'),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ));
      },
      child: Container(
          height: 35,
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
              color: HexColor('#97CDB7'),
              borderRadius: BorderRadius.circular(25)),
          child: Row(
            children: [
              Image.asset(
                coinImageUrl,
                width: 16,
              ),
              const SizedBox(width: 8),
              Text(
                coinName,
                style: const TextStyle(
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
              const SizedBox(width: 10),
              if (isFrom)
                const Icon(
                  Icons.arrow_drop_down_outlined,
                  color: Colors.white,
                )
            ],
          )),
    );
  }
}
