import 'package:http/http.dart';
import 'dart:convert';
import 'package:ggnz/web3dart/web3dart.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:ggnz/utils/enums.dart';
import 'package:ggnz/utils/getx_controller.dart';

Future<Map> GGNZBuyEgg(data) async {
  final db = data["db"];
  final number = data["number"];

  while (true) {
    final prev_count = getx.items[EggType.getById(number).key]?['amount'];

    try {
      await getx.client.sendTransaction(
          getx.credentials,
          Transaction.callContract(
              contract: getx.dAppContract,
              function: getx.dAppContract.function("buyEgg"),
              parameters: [ BigInt.from(number), BigInt.one, getMagicWord(getx.mode) ]
          ),
          chainId: getx.chainID
      );

      while (true) {
        await waitForResult(1500);
        final current_count = (await getx.getEggs([ BigInt.from(number) ]))[0].toInt();
        if (current_count > prev_count) {
          break;
        }
      }

      return Future.value({
        "type": "buying_egg",
        "result": "success"
      });
    } catch (e) {
      if (e.toString().contains("caller is not owner nor approved")) {
        try {
          await getx.client.sendTransaction(
              getx.credentials,
              Transaction.callContract(
                  contract: getx.baitContract,
                  function: getx.baitContract.function("setApprovalForAll"),
                  parameters: [ getx.dAppContract.address, true ]
              ),
              chainId: getx.chainID
          );

          await waitForResult(3000);
        } catch (e) {
          return Future.value({
            "type": "buying_egg",
            "error_message": e.toString(),
            "result": "error"
          });
        }
      } else {
        return Future.value({
          "type": "buying_egg",
          "error_message": e.toString(),
          "result": "error"
        });
      }
    }
  }
}

Future<Map> GGNZBuyItem(data) async {
  final type = data["type"]; // wooden or iron box
  final pay = data["pay"]; // need to pay or already paid.
  final db = data["db"];

  final response = await get(
      Uri.parse("https://us-central1-neezn-ggnz.cloudfunctions.net/box?type=${type == 100? "wooden": "iron"}")
  );

  while (true) {
    try {
      if (pay) {
        final String name = type == 100? ItemBoxType.woodRandomBox.key: ItemBoxType.ironRandomBox.key;
        final int box_num = getx.items[name]!["amount"];
        await getx.client.sendTransaction(
            getx.credentials,
            Transaction.callContract(
                contract: getx.dAppContract,
                function: getx.dAppContract.function("buyRandomBoxes"),
                parameters: [
                  type == 100? BigInt.one: BigInt.two,
                  BigInt.one,
                  getMagicWord(getx.mode)
                ]
            ),
            chainId: getx.chainID
        );

        await waitForResult(2000);
        while (true) {
          await getx.getItems(type == 100? [BigInt.one]: [BigInt.two]);
          if (box_num < getx.items[name]!["amount"]) {
            break;
          }
          await waitForResult(1000);
        }
        getx.timer.updateWoodBox();
      }

      final responseKey = json.decode(response.body)["key"];
      await getx.client.sendTransaction(
          getx.credentials,
          Transaction.callContract(
              contract: getx.dAppContract,
              function: getx.dAppContract.function("unboxBatch"),
              parameters: [
                [ type == 100? BigInt.one: BigInt.two ],
                [ BigInt.from(getx.items[responseKey]!["tokenID"]) ],
                [ BigInt.from(json.decode(response.body)["amount"]) ],
                getMagicWord(getx.mode)
              ]
          ),
          chainId: getx.chainID
      );
      await waitForResult(3000);
      getx.timer.updateMissionCount("Daily1");

      return Future.value({
        "type": "buying_item",
        "itemName": responseKey,
        "tokenID": getx.items[responseKey]!["tokenID"],
        "result": "success",
      });
    } catch (e) {
      if (e.toString().contains("caller is not owner nor approved")) {
        try {
          await getx.client.sendTransaction(
              getx.credentials,
              Transaction.callContract(
                  contract: getx.miscContract,
                  function: getx.miscContract.function("setApprovalForAll"),
                  parameters: [ getx.dAppContract.address, true ]
              ),
              chainId: getx.chainID
          );

          await waitForResult(3000);

          await getx.client.sendTransaction(
              getx.credentials,
              Transaction.callContract(
                  contract: getx.baitContract,
                  function: getx.baitContract.function("setApprovalForAll"),
                  parameters: [ getx.dAppContract.address, true ]
              ),
              chainId: getx.chainID
          );

          await waitForResult(3000);
        } catch (e) {
          return Future.value({
            "result": "error",
            "type": "buying_item",
            "error_message": e.toString(),
          });
        }
      } else {
        return Future.value({
          "result": "error",
          "type": "buying_item",
          "error_message": e.toString(),
        });
      }
    }
  }
}

Future<Map> GGNZReward(data) async {
  final db = data["db"];
  final ids = List<BigInt>.from(data["rewards"].map((x) => BigInt.from(x)));
  final keys = List.generate(ids.length, (index) => BigInt.from(3));
  final amounts = List.generate(ids.length, (index) => BigInt.from(1));

  try {
    await getx.client.sendTransaction(
        getx.credentials,
        Transaction.callContract(
            contract: getx.dAppContract,
            function: getx.dAppContract.function("mintKIP37BatchForUser"),
            parameters: [
              keys,
              ids,
              amounts,
              getMagicWord(getx.mode)
            ]
        ),
        chainId: getx.chainID
    );
    await waitForResult(3000);
    await getx.timer.getRewardMission(data["type"]);

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