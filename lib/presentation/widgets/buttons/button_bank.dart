import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_page.dart';

class ButtonBank extends StatelessWidget {
  const ButtonBank({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const WalletPage(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
      },
      child: Image.asset(
        "assets/bank.png",
        width: 45,
      ),
    );
  }
}
