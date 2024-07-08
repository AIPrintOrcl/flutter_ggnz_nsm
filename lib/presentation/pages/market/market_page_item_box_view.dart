import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/market/market_page_controller.dart';
import 'package:ggnz/presentation/pages/wallet/sign_wallet_page.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ggnz/utils/getx_controller.dart';

class MarketPageItemBoxView extends StatelessWidget {
  const MarketPageItemBoxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketPageController = Get.find<MarketPageController>();
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        for (int i = 0; i < marketPageController.boxImageUrl.length; i++)
          ItemBox(
              imageUrl: marketPageController.boxImageUrl[i],
              price: marketPageController.boxPrices[i])
      ],
    );
  }
}

class ItemBox extends StatelessWidget {
  final String imageUrl;
  final String price;
  const ItemBox({Key? key, required this.imageUrl, required this.price})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketPageController = Get.find<MarketPageController>();
    return InkWell(
      onTap: () {
        if (price == "100" && getx.timer.woodboxCount.value > 0) {
          Get.to(
                  () => SignWalletPage(
                signReason: 'buy_box'.tr,
              ),
              arguments: {
                "reason": price
              });
        }
      },
      child: Obx(() {
        return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            decoration: BoxDecoration(
                color: HexColor('#F4FBEE'),
                border: Border.all(width: 3, color: HexColor('#6D7B76')),
                borderRadius: BorderRadius.circular(25)),
            child: Column(
              children: [
                Image.asset(
                  imageUrl,
                  height: 85,
                ),
                const SizedBox(
                  height: 28,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    Text(price == "100"? getx.timer.woodboxText.value:
                        marketPageController.ironboxText.value,
                        style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: HexColor('#555D42'),
                        ))
                  ],
                )
              ],
            ));
      }),
    );
  }
}
