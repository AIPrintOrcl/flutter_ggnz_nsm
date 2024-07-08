import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_page.dart';
import 'package:hexcolor/hexcolor.dart';

class ButtonPrice extends StatelessWidget {
  final String coinText;
  const ButtonPrice({Key? key, required this.coinText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const WalletPage()),
      child: Container(
        width: 63,
        height: 24,
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
        decoration: BoxDecoration(
            color: Colors.black87.withOpacity(0.5),
            borderRadius: BorderRadius.circular(100)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
                radius: 10,
                backgroundColor: HexColor(
                  "#D9D9D9",
                ),
                child: Text(
                  coinText,
                  style: const TextStyle(
                      fontSize: 8,
                      color: Colors.black,
                      fontWeight: FontWeight.w700),
                )),
            const Center(
              child: Text(
                "0",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
