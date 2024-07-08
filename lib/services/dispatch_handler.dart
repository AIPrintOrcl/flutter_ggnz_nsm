import 'dart:ffi';
import 'dart:math';
import 'package:ggnz/web3dart/web3dart.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/utils/utility_function.dart';

Future<Map> GGNZDispatchHandler(data) async {
  final firestore.FirebaseFirestore db = data["db"];
  final int amount = data["amount"];
  final String id = data["id"];
  final String mint_id = data["mint_id"];
  late final String dispatch_id;
  final double start_bait = getx.bait.value;

  try {
    final dispatch_test_result = await canDispatchDevice(db, id, mint_id);

    if ([2, 4].contains(dispatch_test_result["result"])) {
      return Future.value({
        "type": "dispatch",
        "error_message": "already dispatched from another device",
        "result": "error"
      });
    } else if (dispatch_test_result["result"] == 1) {
      dispatch_id = await adddataUserCollectionDB(db, "dispatch", {
        "id": id,
        "mint_id": mint_id,
        "device": getx.deviceID.value,
        "amount": max(amount, 1),
        "finished": false,
        "error": [],
      }, true);
    } else {
      dispatch_id = dispatch_test_result["docID"];
    }

    await updateUserDB(db, {
      "marimo": firestore.FieldValue.delete()
    }, false);

    await getx.client.sendTransaction(
        getx.credentials,
        Transaction.callContract(
            contract: getx.dAppContract,
            function: getx.dAppContract.function("mintKIP37ForUser"),
            parameters: [
              BigInt.from(2),
              BigInt.one,
              BigInt.from(max(amount, 1)),
              getMagicWord(getx.mode)
            ]
        ),
        chainId: getx.chainID
    );

    while (true) {
      await waitForResult(1500);
      await getx.getWalletCoinBalance(["BAIT"]);
      if (start_bait < getx.bait.value) {
        break;
      }
    }
    await getx.timer.updateMissionCount("Daily2");
    await updateUserCollectionDB(db, "dispatch", dispatch_id, {
      "finished": true
    });

    return Future.value({
      "type": "dispatch",
      "result": "success"
    });
  } catch (e) {
    return Future.value({
      "type": "dispatch",
      "error_message": e.toString(),
      "result": "error"
    });
  }
}