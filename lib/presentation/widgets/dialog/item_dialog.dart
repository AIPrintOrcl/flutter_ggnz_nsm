import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/market/market_page.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/presentation/widgets/buttons/button_item.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/enums.dart';
import 'package:hexcolor/hexcolor.dart';

class ItemDialog extends StatelessWidget {
  const ItemDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncubatorPageController>();
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(url: 'assets/sound/click_menu.mp3');
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/notice_paper.png'),
                fit: BoxFit.contain)),
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  color: HexColor("#555D42"),
                  height: 1.2,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                child: Text(
                  controller.isItemAmountZero
                      ? 'empty_item_dialog_text'.tr
                      : 'item_dialog_text'.tr,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              controller.isItemAmountZero
                  ? ButtonGGnz(
                      width: 179,
                      buttonText: '상점으로 이동',
                      buttonBorderColor: HexColor("#555D42"),
                      buttonColor: HexColor("#DAEAD4"),
                      style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        color: HexColor("#555D42"),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      isBoxShadow: true,
                      onPressed: () {
                        Get.off(() => const MarketPage());
                      })
                  : Container(
                      padding: const EdgeInsets.only(left: 10, right: 20),
                      height: Get.height / 7,
                      child: ListView.separated(
                          separatorBuilder: (context, index) {
                            final abilityType = controller.items[controller
                                .items.keys
                                .toList()[index]]!['abilityType'];
                            final isEmptyItem = controller.items[controller
                                        .items.keys
                                        .toList()[index]]!["amount"] ==
                                    0 ||
                                abilityType == ItemAbilityType.itembox.name ||
                                abilityType == ItemAbilityType.egg.name ||
                                abilityType == ItemAbilityType.mint.name;
                            if (isEmptyItem) {
                              return Container();
                            }
                            return const SizedBox(
                              width: 10,
                            );
                          },
                          padding: const EdgeInsets.all(20),
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.items.keys.length,
                          itemBuilder: (context, index) => Obx(() {
                                final abilityType = controller.items[controller
                                    .items.keys
                                    .toList()[index]]!['abilityType'];

                                final isEmptyItem = controller.items[controller
                                            .items.keys
                                            .toList()[index]]!["amount"] ==
                                        0 ||
                                    abilityType ==
                                        ItemAbilityType.itembox.name ||
                                    abilityType == ItemAbilityType.egg.name ||
                                    abilityType == ItemAbilityType.mint.name;

                                final imageUrl = controller.items[controller
                                    .items.keys
                                    .toList()[index]]!['imageUrl'];

                                final amount = controller.items[controller
                                    .items.keys
                                    .toList()[index]]!['amount'];

                                final isActive = controller.clickedItem ==
                                    controller.items.keys.toList()[index];

                                if (isEmptyItem) {
                                  return Container();
                                }

                                return GestureDetector(
                                    onTap: () {
                                      if (controller.items[controller.items.keys
                                              .toList()[index]]!["amount"] ==
                                          0) {
                                        return;
                                      }
                                      final audioController =
                                          Get.find<AudioController>();
                                      audioController.openAudioPlayer(
                                          url:
                                              'assets/sound/click_move_shop_and_item.mp3');
                                      controller.setClickedItem =
                                          controller.items.keys.toList()[index];
                                    },
                                    child: ButtonItem(
                                        imageUrl: imageUrl,
                                        amount: amount,
                                        isActive: isActive));
                              })),
                    ),
              const ItemDescription(),
              const SizedBox(
                height: 20,
              ),
              ButtonGGnz(
                  width: 179,
                  buttonText: 'continue'.tr,
                  buttonBorderColor: HexColor("#555D42"),
                  buttonColor: HexColor("#DAEAD4"),
                  style: TextStyle(
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    color: HexColor("#555D42"),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  isBoxShadow: true,
                  onPressed: () {
                    Get.back();
                    final audioController = Get.find<AudioController>();
                    audioController.openAudioPlayer(
                        url: 'assets/sound/click_menu.mp3');
                    controller.startTimer(
                        eggsPageNum: controller.indicatorCount,
                        needToPay: true,
                        data: {
                          'health': 0,
                          'time': 0,
                          'marimoPartCheck': [false, false, false, false],
                        }
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemDescription extends StatelessWidget {
  const ItemDescription({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncubatorPageController>();
    return Obx(() {
      final isClickedItemEmpty = controller.clickedItem.isEmpty;
      final abilityCount = controller.items[controller.clickedItem]
              ?['abilityCount']
          .toString()
          .replaceAll('.0', '');

      final name = controller.items[controller.clickedItem]?['name'];

      final itemTo =
          controller.items[controller.clickedItem]?['itemTo'].toString() ==
                  ItemTo.environment.name
              ? 'environment_gauge'.tr
              : 'health_level'.tr;

      final perTime =
          controller.items[controller.clickedItem]?['abilityType'].toString() ==
                  ItemAbilityType.percent.name
              ? 'per_minute'.tr
              : '';

      final abilityType =
          controller.items[controller.clickedItem]?['abilityType'].toString() ==
                  ItemAbilityType.percent.name
              ? '%'
              : '';
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DefaultTextStyle(
            style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: HexColor("#555D42"),
                fontSize: 15),
            child: Text(
              name == null ? '' : name.toString().tr,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          DefaultTextStyle(
            style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: HexColor('#7FC288'),
                fontSize: 17),
            child: Text(
              isClickedItemEmpty
                  ? ''
                  : '$perTime $itemTo\n +$abilityCount$abilityType ${'increase'.tr}',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    });
  }
}
