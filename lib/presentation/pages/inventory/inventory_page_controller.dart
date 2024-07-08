import 'package:get/get.dart';
import 'package:ggnz/utils/getx_controller.dart';

class InventoryPageController extends GetxController {
  final _items = getx.items;
  Map<String, Map<String, dynamic>> get items => _items;

  final _itemKeys = getx.items.keys.toList();
  List<String> get itemKeys => _itemKeys;

  final _itemValues = getx.items.values.toList();
  List<Map<String, dynamic>> get itemValues => _itemValues;
}
