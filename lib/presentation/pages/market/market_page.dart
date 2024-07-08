import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/pages/market/market_page_controller.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketPageController = Get.find<MarketPageController>();
    final controller = Get.find<IncubatorPageController>();
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(
        url: 'assets/sound/click_menu_open_close.mp3');

    if (Get.arguments != null && Get.arguments["market_type"] == 1) {
      marketPageController.setSelectedTabIndex = 1;
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          title: Text('item_shop'.tr,
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
        body: Container(
            padding: EdgeInsets.only(top: Get.mediaQuery.padding.top + 50),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(controller.backgroundStateImage),
              ),
            ),
            child: Obx(() => Container(
                  width: Get.width,
                  height: Get.height,
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  decoration: BoxDecoration(
                      color: marketPageController.selectedTabIndex == 1
                          ? HexColor('FFE9F4')
                          : HexColor('#97CDB7'),
                      border: Border.all(width: 5, color: HexColor('#6D7C76')),
                      borderRadius: BorderRadius.circular(25)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: marketPageController.tabNames
                                .asMap()
                                .entries
                                .map((tabName) => InkWell(
                                      onTap: () {
                                        final audioController =
                                            Get.find<AudioController>();
                                        audioController.openAudioPlayer(
                                            url:
                                                'assets/sound/click_move_shop_and_item.mp3');
                                        marketPageController
                                            .setSelectedTabIndex = tabName.key;
                                      },
                                      child: Opacity(
                                        opacity: marketPageController
                                                    .selectedTabIndex ==
                                                tabName.key
                                            ? 1
                                            : 0.5,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3),
                                            margin: const EdgeInsets.only(
                                                right: 15),
                                            width: Get.width / 4.5,
                                            height: 48,
                                            decoration: BoxDecoration(
                                                color: HexColor('#DAEAD4'),
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: marketPageController
                                                            .selectedTabIndex ==
                                                        tabName.key
                                                    ? Border.all(
                                                        width: 2,
                                                        color:
                                                            HexColor('#555D42'))
                                                    : null),
                                            child: Center(
                                                child: Text(
                                              tabName.value == '상자'
                                                  ? 'item_shop'.tr
                                                  : 'egg'.tr,
                                              style: TextStyle(
                                                  fontFamily:
                                                      'ONE_Mobile_POP_OTF',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                  color: HexColor('#555D42')),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ))),
                                      ),
                                    ))
                                .toList()),
                        marketPageController.seletedTabWidget[
                            marketPageController.selectedTabIndex]
                      ],
                    ),
                  ),
                ))));
  }
}
