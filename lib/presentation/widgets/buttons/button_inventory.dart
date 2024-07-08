import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/inventory/inventory_page.dart';

class ButtonInventory extends StatelessWidget {
  const ButtonInventory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const InventoryPage(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
      },
      child: Image.asset("assets/inventory.png", width: 45),
    );
  }
}
