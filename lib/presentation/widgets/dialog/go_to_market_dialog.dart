import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/market/market_page.dart';
import 'package:ggnz/presentation/widgets/buttons/button_ggnz.dart';
import 'package:hexcolor/hexcolor.dart';

class GoToMarketDialog extends StatelessWidget {
  const GoToMarketDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final redTextStyle = TextStyle(
        fontSize: 20,
        fontFamily: 'ONE_Mobile_POP_OTF',
        color: HexColor('8B345B'));

    final defaultTextStyle = TextStyle(
        fontSize: 20,
        fontFamily: 'ONE_Mobile_POP_OTF',
        color: HexColor("#555D42"));

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
            RichText(
              text: TextSpan(text: '깨울', style: defaultTextStyle, children: [
                TextSpan(text: ' 알', style: redTextStyle),
                TextSpan(text: '이 없습니다.', style: defaultTextStyle)
              ]),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(text: '상점', style: redTextStyle, children: [
                TextSpan(text: '으로', style: defaultTextStyle),
                TextSpan(text: ' 이동하시겠습니까?', style: defaultTextStyle)
              ]),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/market.png'),
            const SizedBox(height: 20),
            ButtonGGnz(
                buttonText: '구입하러 가기',
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
                  Get.off(() => const MarketPage());
                }),
          ],
        ),
      ),
    );
  }
}
