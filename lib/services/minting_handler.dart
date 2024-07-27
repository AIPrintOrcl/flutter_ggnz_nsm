import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'dart:async';
import 'package:ggnz/web3dart/web3dart.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:get/get.dart';
import 'package:ntp/ntp.dart';

Future<Map> GGNZMintingHandler(data) async {
  final firestore.FirebaseFirestore db = data['db'];
  final String docID = data["docID"];
  final int type = data["type"];
  final controller = Get.put(IncubatorPageController());
  final int startat = (await NTP.now()).millisecondsSinceEpoch;
  late final StreamSubscription? firestoreStream;

  try {
    // health 수치 추가 필요
    print("minting docID: " + docID);
    await db.collection(getx.mode == "userId"? "nft_v2": "nft_test").doc(docID).set({
      "address": getx.walletAddress.value,
      "time": startat,
      "parts": controller.marimoPartsNumMap,
      "partsList": controller.marimoList,
      "health": getx.healthLevel.value,
      "environment": getx.environmentLevel.value,
    });

    firestoreStream = await db.collection(getx.mode == "userId"? "nft_v2": "nft_test").doc(docID).snapshots().listen((event) async {
      if (event.data()!["image"] != null) {
        try {
          if (type == 1) {
            /*await getx.client.sendTransaction(
                getx.credentials,
                Transaction.callContract(
                    contract: getx.ggnzContract,
                    function: getx.ggnzContract.function("increaseAllowance"),
                    parameters: [
                      getx.dAppContract.address,
                      BigInt.from(1000 * 1e+18),
                    ]
                ),
                chainId: getx.chainID
            );

            await waitForResult(2000);

            await getx.client.sendTransaction(
                getx.credentials,
                Transaction.callContract(
                  contract: getx.dAppContract,
                  function: getx.dAppContract.function("mintNFTWithGGNZ"),
                  parameters: [BigInt.from(startat), docID, getMagicWord(getx.mode)],
                ),
                chainId: getx.chainID
            );*/
          } else if (type == 2) {
            while (true) {
              try {
                await getx.client.sendTransaction(
                    getx.credentials,
                    Transaction.callContract(
                      contract: getx.dAppContract,
                      function: getx.dAppContract.function("mintNFTWithTicket"),
                      parameters: [BigInt.from(startat), docID, getMagicWord(getx.mode)],
                    ),
                    chainId: getx.chainID
                );

                await waitForResult(3000);
                break;
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
                  } catch (e) {
                    return Future.value({
                      "type": "minting",
                      "error_message": e.toString(),
                      "result": "error"
                    });
                  }
                } else {
                  return Future.value({
                    "type": "minting",
                    "error_message": e.toString(),
                    "result": "error"
                  });
                }
              }
            }
          }

          while (true) {
            final tokenID = await getx.client.call(
              contract: getx.otpContract,
              function: getx.otpContract.function("tokenIds"),
              params: [ docID ],
            );

            if (tokenID[0].toInt() != 0) {
              await db.collection(getx.mode == "abis"? "nft": "nft_test").doc(docID).update({
                "tokenID": tokenID[0].toInt()
              });

              break;
            }

            await waitForResult(3000);
          }

          controller.closeLoadingDialog();
          controller.finishIncubating();
          controller.showSnackBar('minting_complete'.tr);
          await getx.getWalletCoinBalance(["KLAY", "GGNZ"]);
          await getx.getItems([ BigInt.from(20) ]);

          return Future.value({
            "type": "minting",
            "result": "success"
          });
        } catch (e) {
          print("test error from minting: ${e.toString()}");
        }
      }
    });

    return Future.value({
      "type": "minting",
      "result": "success"
    });
  } catch (e) {
    await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
      "minting": {
        "parts": controller.marimoPartsNumMap,
        "partsList": controller.marimoList,
        "result": "error",
        "error": e.toString()
      }
    });

    return Future.value({
      "type": "minting",
      "error_message": e.toString(),
      "result": "error"
    });
  }
}