import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:ggnz/utils/getx_controller.dart';

class CheckAppStateController extends GetxController with WidgetsBindingObserver {
  @override
  void onInit() async {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        getx.isBackground.value = false;
        print('test background check: ${getx.isBackground.value}');
        break;
      case AppLifecycleState.inactive:
        getx.isBackground.value = true;
        print('test background check: ${getx.isBackground.value}');
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }
}
