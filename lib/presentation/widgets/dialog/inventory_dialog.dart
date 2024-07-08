import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/pages/market/market_page_item_box_view.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:ggnz/utils/enums.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ggnz/utils/getx_controller.dart';

class InventoryDialog extends StatelessWidget {
  final String itemName;
  final String itemImageUrl;
  final String itemDescription;
  const InventoryDialog(
      {Key? key,
      required this.itemName,
      required this.itemImageUrl,
      required this.itemDescription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final incubatorPageController = Get.find<IncubatorPageController>();
    return GestureDetector(
      onTap: (() => Get.back()),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/notice_paper.png'),
                fit: BoxFit.contain)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: HexColor("#555D42"),
                height: 1.3,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
              child: Text(
                itemName.tr,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: itemName == ItemBoxType.woodRandomBox.key
                  ? Get.height / 6
                  : Get.height / 5,
              child: Image.asset(
                itemImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                color: HexColor('#7FC288'),
                height: 1.3,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
              child: Text(
                itemDescription.tr,
                textAlign: TextAlign.center,
              ),
            ),
            if (itemName == ItemBoxType.woodRandomBox.key)
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ButtonGGnz(
                      buttonText: 'open_box'.tr,
                      width: 179,
                      buttonBorderColor: HexColor("#555D42"),
                      buttonColor: HexColor("#DAEAD4"),
                      isBoxShadow: true,
                      style: TextStyle(
                        fontFamily: 'ONE_Mobile_POP_OTF',
                        color: HexColor("#555D42"),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      onPressed: () {
                        // 상자를 열었을 때 실행되어야 할 함수
                        if (getx.items["Wood Random Box"]!["amount"] <= 0) {
                          Get.snackbar('${Get.arguments}', '',
                              padding:
                              const EdgeInsets.fromLTRB(10, 30, 10, 10),
                              backgroundColor:
                              HexColor('#2E0C0C').withOpacity(0.7),
                              duration: const Duration(seconds: 2),
                              titleText: Center(
                                  child: Text('not_enough_items'.tr,
                                      style: TextStyle(
                                        fontFamily: 'ONE_Mobile_POP_OTF',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ))));
                        } else {
                          incubatorPageController.buyItem(100, false);
                        }
                        return;
                      }),
                ],
              )
          ],
        ),
      ),
    );
  }
}
