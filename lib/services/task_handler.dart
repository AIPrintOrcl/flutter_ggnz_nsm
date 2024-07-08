import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:ggnz/services/service_functions.dart';
import 'package:ggnz/web3dart/web3dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:crypto/crypto.dart';

import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/utils/utility_function.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';

class GGNZIncubateHandler {
  late final int time_interval; // second
  late Timer incubatorTimer;
  late final int page_num;
  late final int used_item;
  late final String id;
  bool isRunning = false;

  // incubator controller
  late final IncubatorPageController controller;

  // variables for health value
  int health_plus_time = 0;
  late final double health_plus_percent;

  // variables for environment level
  int environmentPlusTime = 0;
  late final double environment_plus_count;

  // firebase db
  late final firestore.FirebaseFirestore db;

  // marimo parts
  late final parts_gage_list;
  final List<int> armParts = List.generate(47, (index) => index + 1);
  final List<int> eyeParts = List.generate(62, (index) => index + 1);
  final List<int> headParts = List.generate(60, (index) => index + 1);
  final List<int> legParts = List.generate(73, (index) => index + 1);
  final List<int> mouseParts = List.generate(71, (index) => index + 1);
  final List<int> tailParts = List.generate(46, (index) => index + 1);
  final List<int> accUpParts = List.generate(49, (index) => index + 1);
  final List<int> accMiddleParts = List.generate(12, (index) => index + 1);
  final bool isAccMiddlePart = Random().nextBool();
  late List<bool> marimoPartCheck = [false, false, false, false];
  late List<String> marimoList;
  late Map<String, String> marimoPartsNumMap;
  late final Map initial_data;

  int current_time = 0;

  GGNZIncubateHandler(data) {
    controller = Get.put(IncubatorPageController());
    initial_data = data;

    db = initial_data["db"];
    id = initial_data["id"];
    time_interval = initial_data["time_interval"];
    page_num = initial_data["page_num"];
    used_item = initial_data["used_item"];
    health_plus_percent = initial_data["health_plus_percent"];
    environment_plus_count = initial_data["environment_plus_count"];
    parts_gage_list = controller.partsGageList;
    current_time = initial_data["time"];
    marimoPartCheck = initial_data["marimoPartCheck"]?.cast<bool>();

    // marimo parts
    marimoList = controller.marimoList;
    marimoPartsNumMap = controller.marimoPartsNumMap;
  }

  Future<Map> initIncubator(bool needToPay) async {
    while (true) {
      try {
        if (needToPay) {
          await getx.client.sendTransaction(
              getx.credentials,
              Transaction.callContract(
                  contract: getx.dAppContract,
                  function: getx.dAppContract.function("sendKIP37ForUser"),
                  parameters: [
                    BigInt.one,
                    BigInt.from(page_num + 1),
                    BigInt.one,
                    getMagicWord(getx.mode)
                  ]),
              chainId: getx.chainID);

          await updateUserDB(db, {
            "marimo.eggID": page_num + 1,
            "marimo.id": id,
            "marimo.time": current_time + 1,
            "marimo.marimoList": marimoList,
            "marimo.marimoPartsNumMap": marimoPartsNumMap,
            "marimo.time_interval": time_interval,
            "marimo.marimoPartCheck": marimoPartCheck,
            "marimo.environmentTime": getx.environmentTime.value,
          }, false);

          if (used_item != -1) {
            await getx.client.sendTransaction(
                getx.credentials,
                Transaction.callContract(
                    contract: getx.dAppContract,
                    function: getx.dAppContract.function("sendKIP37ForUser"),
                    parameters: [
                      BigInt.from(3),
                      BigInt.from(used_item),
                      BigInt.one,
                      getMagicWord(getx.mode)
                    ]),
                chainId: getx.chainID);

            getx.environmentLevel.value = getx.environmentLevel.value + initial_data["environment_initial"];
            getx.healthLevel.value = initial_data["health_initial"];

            await updateUserDB(db, {
              "marimo.itemID": used_item,
              "marimo.health": getx.healthLevel.value,
              "environmentLevel": getx.environmentLevel.value,
            }, false);
          }
        } else {
          getx.healthLevel.value = initial_data["health_initial"];
        }

        await waitForResult(3000);

        return Future.value({
          "type": "awake_egg",
          "result": "success",
          "used_item": used_item,
        });
      } catch (e) {
        if (e.toString().contains("caller is not owner nor approved")) {
          try {
            await getx.client.sendTransaction(
                getx.credentials,
                Transaction.callContract(
                    contract: getx.eggContract,
                    function: getx.eggContract.function("setApprovalForAll"),
                    parameters: [getx.dAppContract.address, true]),
                chainId: getx.chainID);

            await db
                .collection(getUserCollectionName(getx.mode))
                .doc(getx.walletAddress.value)
                .update({"setApprovalForEgg": true});
            await waitForResult(3000);
          } catch (e) {
            return Future.value({
              "type": "awake_egg",
              "error_message": e.toString(),
              "result": "error"
            });
          }
        } else {
          return Future.value({
            "type": "awake_egg",
            "error_message": e.toString(),
            "result": "error"
          });
        }
      }
    }
  }

  double getHealthPlusCount() {
    double countFromEnvironmentState =
        getx.environmentLevel.value < getx.environmentBad
            ? -1
            : getx.environmentLevel.value > getx.environmentNormal
                ? 1
                : 0;

    final double random_health_value = ((page_num + 2) / 2 + countFromEnvironmentState)
        * (1 + health_plus_percent / 100)
        + (Random().nextInt(2) - 1);
    return max(random_health_value, 0.1);
  }

  bool getMarimoParts(int tick) {
    bool result = false;

    if (!marimoPartCheck[0] && tick >= parts_gage_list[0]) {
      marimoList[0] = "assets/parts/tail/ts.gif";
      marimoList[2] = "assets/parts/tail/t0.gif";
      marimoList[6] = "assets/parts/head/h0.gif";
      eyeParts.shuffle();
      marimoList[7] = "assets/parts/eye/e${eyeParts[0]}.gif";
      marimoPartsNumMap['eye'] = eyeParts[0].toString();
      mouseParts.shuffle();
      marimoList[8] = "assets/parts/mouse/m${mouseParts[0]}.gif";
      marimoPartsNumMap['mouse'] = mouseParts[0].toString();
      tailParts.shuffle();
      marimoList[1] = "assets/parts/tail/t${tailParts[0]}.gif";
      marimoPartsNumMap['tail'] = tailParts[0].toString();
      marimoPartCheck[0] = true;
      result = true;
    }
    if (!marimoPartCheck[1] && tick >= parts_gage_list[1]) {
      legParts.shuffle();
      marimoList[3] = "assets/parts/leg/l0.gif";
      marimoList[4] = "assets/parts/leg/l${legParts[0]}.gif";
      marimoPartsNumMap['leg'] = legParts[0].toString();
      headParts.shuffle();
      marimoList[9] = "assets/parts/head/h${headParts[0]}.gif";
      marimoPartsNumMap['head'] = headParts[0].toString();
      marimoPartCheck[1] = true;
      result = true;
    }
    if (!marimoPartCheck[2] && tick >= parts_gage_list[2]) {
      armParts.shuffle();
      marimoList[5] = "assets/parts/arm/a0.gif";
      marimoList[12] = "assets/parts/arm/a${armParts[0]}.gif";
      marimoPartsNumMap['arm'] = armParts[0].toString();
      marimoPartCheck[2] = true;
      result = true;
    }
    if (!marimoPartCheck[3] &&
        tick >= parts_gage_list[3] &&
        time_interval == parts_gage_list[4]) {
      accUpParts.shuffle();
      marimoList[11] = "assets/parts/accessory/up/acc_up${accUpParts[0]}.gif";
      marimoPartsNumMap['acc_up'] = accUpParts[0].toString();

      accMiddleParts.shuffle();
      marimoList[10] = isAccMiddlePart
          ? "assets/parts/accessory/middle/acc_middle${accMiddleParts[0]}.gif"
          : '';
      marimoPartsNumMap['acc_middle'] =
          isAccMiddlePart ? accMiddleParts[0].toString() : '';
      marimoPartCheck[3] = true;
      result = true;
    }

    return result;
  }

  void startIncubating() async {
    isRunning = true;
    incubatorTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (current_time <= time_interval) {
        if (controller.eggAwake && current_time > 3) {
          controller.setEggAwake = false; // set eggAwake to false after 4 second
        }

        // edit health level
        health_plus_time++;
        if (health_plus_time >= 60) {
          getx.healthLevel.value += getHealthPlusCount();
          health_plus_time = 0;
        }

        final saveToDB = getMarimoParts(current_time); // make marimo parts
        controller.setMarimoGage(page_num, time_interval, current_time.toDouble());

        if (saveToDB) {
          await saveMarimoData();
        }
      } else {
        if (controller.isPlaying) {
          controller.setIsPlaying = false;
          controller.setIsIncubatorDone = true;
          await saveMarimoData();
        }

        if (!controller.isPlaying &&
            controller.isIncubatorDone &&
            controller.checkMintingStream == null) {
          final String docID =
              sha256.convert(utf8.encode(marimoList.toString())).toString();
          controller.checkMintingStream = db
              .collection(getx.mode == "abis" ? "nft" : "nft_test")
              .doc(docID)
              .snapshots()
              .listen((event) {
            controller.setIsAbleMint(!event.exists);
          });

          controller.emotionAudioController
              .openAudioPlayer(url: 'assets/sound/emotion_imoticon.mp3');
        }
      }

      environmentPlusTime++;
      if (environmentPlusTime >= 60) {
        getx.environmentLevel.value =
            min(getx.environmentLevel.value + environment_plus_count, 600);
        environmentPlusTime = 0;
      }

      current_time++;
    });
  }

  void resumeIncubating(int diffTime) async {
    final remain_time = max(time_interval - current_time, 0);
    current_time += diffTime;

    if (controller.eggAwake && current_time > 3) {
      controller.setEggAwake = false; // set eggAwake to false after 4 second
    }

    // set main timer
    getx.environmentTime.value += min(diffTime, remain_time);

    health_plus_time += min(diffTime, remain_time);
    if (health_plus_time >= 60) {
      for (int i = 0; i < (health_plus_time ~/ 60); i++) {
        getx.healthLevel.value += getHealthPlusCount();
      }
      health_plus_time = health_plus_time % 60;
    }

    final saveToDB = getMarimoParts(current_time); // make marimo parts
    controller.setMarimoGage(page_num, time_interval, current_time.toDouble());

    environmentPlusTime += diffTime;
    if (environmentPlusTime >= 60) {
      getx.environmentLevel.value = min(
          getx.environmentLevel.value +
              environment_plus_count * (environmentPlusTime ~/ 60),
          600);
      environmentPlusTime = environmentPlusTime % 60;
    }

    await saveMarimoData();
    startIncubating();
  }

  Future<void> saveMarimoData() async {
    await updateUserDB(db, {
      "environmentLevel": getx.environmentLevel.value,
      "marimo.eggID": page_num + 1,
      "marimo.health": getx.healthLevel.value,
      "marimo.time": current_time + 1,
      "marimo.marimoList": marimoList,
      "marimo.marimoPartsNumMap": marimoPartsNumMap,
      "marimo.time_interval": time_interval,
      "marimo.marimoPartCheck": marimoPartCheck,
      "marimo.environmentTime": getx.environmentTime.value,
    }, false);
  }

  void pauseIncubating() {
    isRunning = false;
    incubatorTimer.cancel();
  }

  String getID() {
    return id;
  }
}
