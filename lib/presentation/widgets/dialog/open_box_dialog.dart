import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/inventory/inventory_page.dart';
import 'package:ggnz/presentation/pages/market/market_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'dart:convert';

class OpenBoxDialog extends StatefulWidget {
  final String imageUrl;
  final String boxType;
  final String itemName;
  const OpenBoxDialog({Key? key, required this.imageUrl, required this.boxType,
    required this.itemName})
      : super(key: key);

  @override
  State<OpenBoxDialog> createState() => _OpenBoxDialogState();
}

class _OpenBoxDialogState extends State<OpenBoxDialog> {
  @override
  void dispose() {
    imageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketPageController = Get.find<MarketPageController>();
    final bgmAudioPlayer = Get.find<BgmController>();
    marketPageController.pickedItem(widget.itemName);
    RxBool isItemShow = false.obs;
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(url: 'assets/sound/box_purchase.mp3');
    Future.delayed(const Duration(milliseconds: 4500), (() {
      isItemShow.value = true;
      audioController.openAudioPlayer(url: 'assets/sound/box_show_item.mp3');
    }));
    bgmAudioPlayer.stopAndPlayBgm(playTime: 7);

    return Obx(() => Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'assets/notice_paper.png',
                  fit: BoxFit.cover,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 5),
                    DefaultTextStyle(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: HexColor('#555D42'),
                        ),
                        child: Text('check_what_item_was_found'.tr)),
                    Image.asset(
                      widget.imageUrl,
                      width: Get.height / 4,
                    ),
                    DottedBorder(
                      strokeWidth: 1,
                      color: Colors.black26,
                      dashPattern: [5, 5],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(15),
                      padding: EdgeInsets.all(6),
                      child: Container(
                          width: 85,
                          height: 85,
                          child: AnimatedOpacity(
                            duration: const Duration(seconds: 2),
                            opacity: isItemShow.value ? 1 : 0,
                            child: Image.asset(
                              marketPageController.pickedItmeImageUrl,
                            ),
                          )),
                    ),
                    const Spacer(flex: 1),
                    ButtonGGnz(
                        width: 179,
                        buttonText: 'go_to_inventory'.tr,
                        buttonBorderColor: HexColor("#555D42"),
                        buttonColor: HexColor("#DAEAD4"),
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: HexColor("#555D42"),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        isBoxShadow: true,
                        onPressed: (() {
                          Get.back();
                          Get.off(() => const InventoryPage(),
                              transition: Transition.noTransition,
                              duration: const Duration(milliseconds: 500));
                        })),
                    const Spacer(flex: 5),
                  ],
                ),
              ]),
        ));
  }
}
