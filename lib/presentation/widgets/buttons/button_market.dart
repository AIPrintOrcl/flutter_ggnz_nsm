import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/market/market_page.dart';

class ButtonMarket extends StatelessWidget {
  const ButtonMarket({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const MarketPage(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
      },
      child: Image.asset("assets/market.png", width: 45),
    );
  }
}
