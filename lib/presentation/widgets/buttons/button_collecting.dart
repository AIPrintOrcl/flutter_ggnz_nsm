import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/collecting/collecting_page.dart';

class ButtonCollecting extends StatelessWidget {
  const ButtonCollecting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const CollectingPage(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
      },
      child: Image.asset("assets/collection.png", width: 45),
    );
  }
}
