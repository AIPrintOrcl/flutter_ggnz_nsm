import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:ggnz/web3dart/web3dart.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:ggnz/utils/enums.dart';
import 'package:ggnz/utils/getx_controller.dart';

import '../utils/utility_function.dart';

Future<Map> GGNZBuyEgg(data) async {
  final db = data["db"];
  final number = data["number"];

  try {
    await updateUserDB(db, {
      'eggs.${number}': firestore.FieldValue.increment(1)
    }, false);
    await getx.getEggs([ BigInt.from(number) ]);

    return Future.value({
      "type": "buying_egg",
      "result": "success"
    });
  } catch (e) {
    return Future.value({
      "type": "buying_egg",
      "error_message": e.toString(),
      "result": "error"
    });
  }
}

Future<Map> GGNZBuyItem(data) async {
  final type = data["type"]; // wooden or iron box
  final pay = data["pay"]; // need to pay or already paid.
  final db = data["db"];

  final response = await get(
      Uri.parse("https://us-central1-neezn-ggnz.cloudfunctions.net/box?type=${type == 100? "wooden": "iron"}")
  );

  try {
    getx.timer.updateWoodBox();
    final responseKey = json.decode(response.body)["key"];
    final itemId = getx.items[responseKey]!["tokenID"].toString();
    final amount = json.decode(response.body)["amount"].toInt();

    await updateUserDB(db, {
      'items.$itemId': firestore.FieldValue.increment(amount)
    }, false);

    getx.timer.updateMissionCount("Daily1");

    return Future.value({
      "type": "buying_item",
      "itemName": responseKey,
      "tokenID": getx.items[responseKey]!["tokenID"],
      "result": "success",
    });
    } catch (e) {
    return Future.value({
      "result": "error",
      "type": "buying_item",
      "error_message": e.toString(),
    });
  }
}

Future<Map> GGNZReward(data) async {
  final db = data["db"];
  final ids = List<BigInt>.from(data["rewards"].map((x) => BigInt.from(x)));
  final keys = List.generate(ids.length, (index) => BigInt.from(3));
  final amounts = List.generate(ids.length, (index) => BigInt.from(1));

  try {
    Map<Object, Object> updateData = {
      "getReward.${data["type"]}.isGetRewards": true
    };
    for (final id in ids) {
      updateData['items.${id}'] = firestore.FieldValue.increment(1);
    }

    getx.getReward.value[data["type"]]["isGetRewards"] = true;
    await updateUserDB(db, updateData, false);

    return Future.value({
      "type": "get_rewards",
      "ids": ids,
      "result": "success",
    });
  } catch (e) {
    return Future.value({
      "type": "get_rewards",
      "error_message": e.toString(),
      "result": "error"
    });
  }
}