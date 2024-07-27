import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:ggnz/utils/getx_controller.dart';

// 앱이 활성화/비활성화 될 때 특정 동작 수행. WidgetBindingObserver를 통해 앱 라이프사이클의 상태 변화 감지/미감지 및 getx.isBackground를 true/false로 변경
class CheckAppStateController extends GetxController with WidgetsBindingObserver {
  @override
  void onInit() async { /* onInit() : 컨트롤러 초기화 시 호출 */
    super.onInit();
    WidgetsBinding.instance.addObserver(this); /* 현재 객체를 WidgetBindingObserver로 등록하여 앱 라이프사이클의 상태 변화를 감지 */
  }

  @override
  void onClose() { /* onClose() : 컨트롤러가 삭제될 때 호출됨*/
    WidgetsBinding.instance.removeObserver(this); /* 객체를 WidgetsBindingObserver에서 제거하여 더 이상 상태 변화를 감지하지 않음 */
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async { /* didChangeAppLifecycleState() : 앱의 라이프사이클 상태가 변경될 때 호출 */
    switch (state) {
      case AppLifecycleState.resumed: /* resumed : 앱이 다시 활성화되었을 때 */
        getx.isBackground.value = false; /* 앱이 백그라운드 상태가 아님 */
        print('test background check: ${getx.isBackground.value}');
        break;
      case AppLifecycleState.inactive: /* inactive : 앱이 비활성화되었을 때 */
        getx.isBackground.value = true; /* 앱이 백그라운드 상태에 있음 */
        print('test background check: ${getx.isBackground.value}');
        break;
      case AppLifecycleState.paused: /* paused : 앱이 일시 중지되었을 때 */
        break;
      case AppLifecycleState.detached: /* detached : 앱이 분리되었을 때 (사용하지 않을 때) */
        break;
    }
  }
}
