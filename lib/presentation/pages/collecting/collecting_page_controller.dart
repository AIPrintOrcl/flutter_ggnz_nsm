import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/collecting/collecting_page_collecting_view.dart';
import 'package:ggnz/presentation/pages/collecting/collecting_page_encyclopedia_view.dart';
import 'package:ggnz/presentation/pages/collecting/collecting_page_mission_view.dart';
import 'package:ggnz/presentation/pages/collecting/collecting_view_controller.dart';
import 'package:ggnz/presentation/pages/collecting/encyclopedia_view_controller.dart';
import 'package:ggnz/presentation/pages/collecting/mission_view_controller.dart';

class CollectingPageController extends GetxController {
  List<String> tabNames = ['도감', '콜렉팅 미션', '일반 미션'];

  final _selectedTabIndex = 0.obs;
  int get selectedTabIndex => _selectedTabIndex.value;
  set setSelectedTabIndex(int tabIndex) => _selectedTabIndex.value = tabIndex;

  List<Widget> seletedTabWidget = [
    const CollectingPageEncyclopediaView(),
    const CollectingPageCollectingView(),
    const CollectingPageMissionView()
  ];
  final encyclopediaController = Get.put(EncyclopediaViewController());
  final collectingController = Get.put(CollectingViewController());
  final missionController = Get.put(MissionViewController());

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {}
}
