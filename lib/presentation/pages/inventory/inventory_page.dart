import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/pages/inventory/inventory_page_controller.dart';
import 'package:ggnz/presentation/widgets/dialog/inventory_dialog.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/enums.dart';
import 'package:hexcolor/hexcolor.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inventoryPageController = Get.put(InventoryPageController());
    final controller = Get.find<IncubatorPageController>();
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(
        url: 'assets/sound/click_menu_open_close.mp3');

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          title: Text('inventory'.tr,
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
          backgroundColor: Colors.transparent,
        ),
        body: Obx(
          () => Container(
              padding: EdgeInsets.only(top: Get.mediaQuery.padding.top + 50),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(controller.backgroundStateImage),
                ),
              ),
              child: Container(
                  width: Get.width,
                  height: Get.height,
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  decoration: BoxDecoration(
                      color: HexColor('#F4FBEE'),
                      border: Border.all(width: 5, color: HexColor('#6D7C76')),
                      borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    mainAxisExtent: Get.height / 5),
                            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                            controller: ScrollController(),
                            itemCount: inventoryPageController.itemKeys.length,
                            itemBuilder: ((context, index) {
                              final itemCount = inventoryPageController.items[
                                  inventoryPageController
                                      .itemKeys[index]]!['amount'];
                              final itemName = inventoryPageController.items[
                                  inventoryPageController
                                      .itemKeys[index]]!['name'];
                              final itemImageUrl =
                                  inventoryPageController.items[
                                      inventoryPageController
                                          .itemKeys[index]]!['imageUrl'];

                              final inventoryItemDescription =
                                  inventoryPageController.items[
                                      inventoryPageController.itemKeys[
                                          index]]!['inventoryItemDescription'];

                              return GestureDetector(
                                onTap: () {
                                  if (itemCount > 0) {
                                    final audioController =
                                        Get.find<AudioController>();
                                    audioController.openAudioPlayer(
                                        url: 'assets/sound/click_menu.mp3');
                                    Get.dialog(InventoryDialog(
                                      itemName: itemName,
                                      itemImageUrl: itemImageUrl,
                                      itemDescription: inventoryItemDescription,
                                    ));
                                  }
                                },
                                child: InventoryPageItem(
                                  itemCount: itemCount,
                                  itemName: itemName,
                                  itemImageUrl: itemImageUrl,
                                ),
                              );
                            })),
                      ),
                    ],
                  ))),
        ));
  }
}

class InventoryPageItem extends StatelessWidget {
  final int itemCount;
  final String itemName;
  final String itemImageUrl;

  const InventoryPageItem(
      {Key? key,
      required this.itemCount,
      required this.itemName,
      required this.itemImageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isItemZero = itemCount == 0;
    return Opacity(
      opacity: isItemZero ? 0.7 : 1,
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(width: 3, color: HexColor('#6D7B76')),
          borderRadius: BorderRadius.circular(20),
          color: HexColor('#F4FBEE'),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GridTile(
              header: const Text(
                '',
                textAlign: TextAlign.center,
              ),
              footer: Text(isItemZero ? '???' : itemName.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    color: HexColor("#555D42"),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  )),
              child: Column(
                children: [
                  if (itemName == ItemBoxType.woodRandomBox.key ||
                      itemName == ItemBoxType.ironRandomBox.key)
                    const SizedBox(
                      height: 10,
                    ),
                  Image.asset(
                    itemImageUrl,
                    color: isItemZero ? Colors.grey : null,
                  ),
                ],
              ),
            ),
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: HexColor('FC8970')),
                  child: Center(
                      child: Text(
                    '$itemCount',
                    style: const TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ))),
            )
          ],
        ),
      ),
    );
  }
}
