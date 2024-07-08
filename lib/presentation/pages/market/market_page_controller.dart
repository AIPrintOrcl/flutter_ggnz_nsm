import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/market/market_page_egg_view.dart';
import 'package:ggnz/presentation/pages/market/market_page_item_box_view.dart';
import 'package:ggnz/utils/enums.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ntp/ntp.dart';

class MarketPageController extends GetxController {
  final _items = getx.items;
  Map<String, Map<String, dynamic>> get items => _items;

  final _itemKeys = getx.items.keys.toList();
  List<String> get itemKeys => _itemKeys;

  final _itemValues = getx.items.values.toList();
  List<Map<String, dynamic>> get itemValues => _itemValues;

  List<String> tabNames = ['상자', '알'];

  final _selectedTabIndex = 0.obs;
  int get selectedTabIndex => _selectedTabIndex.value;
  set setSelectedTabIndex(int tabIndex) => _selectedTabIndex.value = tabIndex;
  final ironboxText = "coming soon".obs;

  List<String> boxImageUrl = ['assets/wooden_box.png', 'assets/iron_box.png'];
  List<String> boxPrices = ['100', '300'];

  final _pickedItemName = ''.obs;
  final _pickedItemImageUrl = ''.obs;

  String get pickedItemName => _pickedItemName.value;
  String get pickedItmeImageUrl => _pickedItemImageUrl.value;

  void pickedItem(String itemName) {
    _pickedItemImageUrl.value = items[itemName]!['imageUrl'];
  }

  List<String> eggImageUrl = [
    EggType.egg.imageUrl,
    EggType.eggSpecial.imageUrl,
    EggType.eggPremium.imageUrl
  ];
  List<Widget> seletedTabWidget = [
    const MarketPageItemBoxView(),
    const MarketPageEggView(),
  ];

  /*String getTimeFormat(int diff) {
    String result = "";
    diff = 12 * 60 * 60 - diff;
    int hours = diff ~/ 3600;
    int minutes = (diff - hours * 3600) ~/ 60;
    int seconds = (diff - hours * 3600 - minutes * 60);
    result = hours.toString() + ":" + minutes.toString() + ":" + seconds.toString() + "";

    return result;
  }*/
}
