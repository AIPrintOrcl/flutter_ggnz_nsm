import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/collecting/collecting_page_controller.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class CollectingPage extends StatelessWidget {
  const CollectingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collectingPageController = Get.find<CollectingPageController>();
    final controller = Get.find<IncubatorPageController>();
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(
        url: 'assets/sound/click_menu_open_close.mp3');

    if (Get.arguments != null && Get.arguments["market_type"] == 1) {
      collectingPageController.setSelectedTabIndex = 1;
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          title: Text('도감 & 콜렉션',
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
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                      color: HexColor('#DAEAD4'),
                      border: Border.all(width: 5, color: HexColor('#6D7C76')),
                      borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    children: [
                      CollectionTabs(
                          collectingPageController: collectingPageController),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: collectingPageController.seletedTabWidget[
                            collectingPageController.selectedTabIndex],
                      )
                    ],
                  ),
                ))));
  }
}

class CollectionTabs extends StatelessWidget {
  final CollectingPageController collectingPageController;
  const CollectionTabs({Key? key, required this.collectingPageController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: collectingPageController.tabNames
            .asMap()
            .entries
            .map((tabName) => InkWell(
                  onTap: () {
                    final audioController = Get.find<AudioController>();
                    audioController.openAudioPlayer(
                        url: 'assets/sound/click_move_shop_and_item.mp3');
                    collectingPageController.setSelectedTabIndex = tabName.key;
                  },
                  child: Opacity(
                    opacity:
                        collectingPageController.selectedTabIndex == tabName.key
                            ? 1
                            : 0.5,
                    child: Container(
                        width: Get.width / 3,
                        height: 48,
                        decoration: BoxDecoration(
                            color: HexColor('#F4FBEE'),
                            borderRadius: BorderRadius.circular(10),
                            border: collectingPageController.selectedTabIndex ==
                                    tabName.key
                                ? Border.all(
                                    width: 2, color: HexColor('#555D42'))
                                : null),
                        child: Center(
                            child: Text(tabName.value,
                                style: TextStyle(
                                    fontFamily: 'ONE_Mobile_POP_OTF',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: HexColor('#555D42'))))),
                  ),
                ))
            .toList());
  }
}
