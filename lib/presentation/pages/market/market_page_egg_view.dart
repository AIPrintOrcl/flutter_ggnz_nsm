import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/presentation/pages/market/market_page_controller.dart';
import 'package:ggnz/presentation/pages/wallet/sign_wallet_page.dart';
import 'package:ggnz/utils/launch_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class MarketPageEggView extends StatelessWidget {
  const MarketPageEggView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketPageController = Get.find<MarketPageController>();
    return Expanded(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Stack(
            children: <Widget>[
              Text(
                'select_egg'.tr,
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: 17,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = HexColor('#555D42'),
                ),
              ),
              Text(
                'select_egg'.tr,
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: Get.height / 3.5),
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                controller: ScrollController(),
                itemCount: marketPageController.eggImageUrl.length,
                itemBuilder: ((context, index) {
                  if (index == marketPageController.eggImageUrl.length) {
                    /*return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ButtonGGnz(
                              textWidget: RichText(
                                text: TextSpan(
                                    text: 'GOP',
                                    style: TextStyle(
                                        fontFamily: 'ONE_Mobile_POP_OTF',
                                        color: HexColor('8B345B')),
                                    children: [
                                      TextSpan(
                                          text: ' 보러가기',
                                          style: TextStyle(
                                              fontFamily: 'ONE_Mobile_POP_OTF',
                                              color: HexColor('#6D7B76')))
                                    ]),
                              ),
                              buttonColor: HexColor('#F4FBEE'),
                              buttonBorderColor: HexColor('#6D7B76'),
                              onPressed: () {
                                launchURL(
                                    'https://opensea.io/collection/gaeguneez-of-the-planet');
                              },
                              isBoxShadow: false),
                          const SizedBox(
                            height: 10,
                          ),
                          ButtonGGnz(
                              textWidget: RichText(
                                text: TextSpan(
                                    text: 'GOG',
                                    style: TextStyle(
                                        fontFamily: 'ONE_Mobile_POP_OTF',
                                        color: Colors.green),
                                    children: [
                                      TextSpan(
                                          text: ' 보러가기',
                                          style: TextStyle(
                                              fontFamily: 'ONE_Mobile_POP_OTF',
                                              color: HexColor('#6D7B76')))
                                    ]),
                              ),
                              buttonColor: HexColor('#F4FBEE'),
                              buttonBorderColor: HexColor('#6D7B76'),
                              onPressed: () {
                                launchURL(
                                    'https://opensea.io/collection/gaeguneez-of-the-galaxy');
                              },
                              isBoxShadow: false)
                        ]);*/
                  }

                  final eggImageUrl = marketPageController.eggImageUrl[index];

                  return GestureDetector(
                    onTap: () async {
                      print(
                          "test index: $index gop: ${getx.gop}, gog: ${getx.gog}");
                      if (index == 1 && getx.gop == 0.0) {
                        showSnackBar('gop_holder_only_message'.tr);
                      } else if (index == 2 && getx.gog == 0.0) {
                        showSnackBar('gog_holder_only_message'.tr);
                      } else {
                        Get.to(() => SignWalletPage(signReason: 'buy_egg'.tr),
                            arguments: {"reason": "egg", "number": index + 1});
                      }
                    },
                    child: EggBox(imageUrl: eggImageUrl, index: index),
                  );
                })),
          ),
        ],
      ),
    );
  }

  void showSnackBar(s) {
    Get.snackbar('${Get.arguments}', '',
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
        backgroundColor: HexColor('#2E0C0C').withOpacity(0.7),
        duration: const Duration(seconds: 2),
        titleText: Center(
            child: Text(s,
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ))));
  }
}

class EggBox extends StatelessWidget {
  final String imageUrl;
  final int index;

  const EggBox({Key? key, required this.imageUrl, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: HexColor('#6D7B76'),
              border: Border.all(width: 0, color: HexColor('#6D7B76')),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  index == 1
                      ? 'special_egg'.tr
                      : index == 2
                          ? 'premium_egg'.tr
                          : 'ggnz_egg'.tr,
                  style: const TextStyle(
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
                color: HexColor('#F4FBEE'),
                border: Border.all(width: 3, color: HexColor('#6D7B76')),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(imageUrl, height: 80),
                    SizedBox(
                      width: Get.width * 0.25,
                      child: RichText(
                          textAlign: TextAlign.center,
                          textWidthBasis: TextWidthBasis.parent,
                          text: TextSpan(
                              text: index == 1
                                  ? 'gop_holder_only'.tr.replaceRange(3, null, '')
                                  : index == 2
                                  ? 'gog_holder_only'
                                  .tr
                                  .replaceRange(3, null, '')
                                  : 'everyone'.tr,
                              style: TextStyle(
                                height: 1.3,
                                fontFamily: 'ONE_Mobile_POP_OTF',
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: index == 1
                                    ? HexColor('8B345B')
                                    : index == 2
                                    ? Colors.green
                                    : HexColor('#6D7B76'),
                              ),
                              children: [
                                TextSpan(
                                    text: index == 1
                                        ? 'gop_holder_only'
                                        .tr
                                        .replaceRange(0, 3, '')
                                        : index == 2
                                        ? 'gog_holder_only'
                                        .tr
                                        .replaceRange(0, 3, '')
                                        : '',
                                    style: TextStyle(
                                      height: 1.3,
                                      fontFamily: 'ONE_Mobile_POP_OTF',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: HexColor('#6D7B76'),
                                    ))
                              ])),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
