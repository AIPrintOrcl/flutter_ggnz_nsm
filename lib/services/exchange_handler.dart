import 'package:ggnz/web3dart/web3dart.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:ggnz/utils/getx_controller.dart';

Future<Map> GGNZExchangeCoin(data) async {
  final from = data["from"];
  final to = data["to"];
  final amount = data["amount"];
  final db = data["db"];

  if (from == "GGNZ" && to == "BAIT") {
    try {
      await getx.client.sendTransaction(
          getx.credentials,
          Transaction.callContract(
              contract: getx.ggnzContract,
              function: getx.ggnzContract.function("increaseAllowance"),
              parameters: [
                getx.dAppContract.address,
                BigInt.from(amount * 1e+18),
              ]
          ),
          chainId: getx.chainID
      );

      await waitForResult(2000);
      await getx.client.sendTransaction(
          getx.credentials,
          Transaction.callContract(
              contract: getx.dAppContract,
              function: getx.dAppContract.function("buyBaitFromGGNZ"),
              parameters: [ BigInt.from(amount / getx.baitPrice), getMagicWord(getx.mode)]
          ),
          chainId: getx.chainID
      );

      await waitForResult(5000);
      return Future.value({
        "type": "exchange_coin",
        "result": "success"
      });
    } catch (e) {
      return Future.value({
        "type": "exchange_coin",
        "error_message": e.toString(),
        "result": "error"
      });
    }
  } else if (from == "BAIT" && to == "GGNZ") {
    while (true) {
      try {
        //RPCError: got code 3 with msg "execution reverted: KIP7: transfer amount exceeds balance". ggnz 부족
        await getx.client.sendTransaction(
            getx.credentials,
            Transaction.callContract(
                contract: getx.dAppContract,
                function: getx.dAppContract.function("buyGGNZFromBait"),
                parameters: [ BigInt.from(amount), getMagicWord(getx.mode)]
            ),
            chainId: getx.chainID
        );

        await waitForResult(5000);
        return Future.value({
          "type": "exchange_coin",
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
              "type": "exchange_coin",
              "error_message": e.toString(),
              "result": "error"
            });
          }
        } else {
          return Future.value({
            "type": "exchange_coin",
            "error_message": e.toString(),
            "result": "error"
          });
        }
      }
    }
  }

  return Future.value({

  });
}