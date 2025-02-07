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
  bool isRunning = false; /* 부화 프로세스 실행 상태 */

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

  // 사용자가 결제 지불해야 하는지 여부에 따라 marimo의 incubator을 초기화 기능 수행
  Future<Map> initIncubator(bool needToPay) async {
    try {
      if (needToPay) {
        final egg_amount = (await db.collection(getUserCollectionName(getx.mode))
            .doc(getx.walletAddress.value).get()).data()?['eggs']?['${page_num + 1}'] ?? 0;

        if (egg_amount < 1) {
          throw Error();
        }

        var updateData = {
          "eggs.${page_num + 1}": firestore.FieldValue.increment(-1),
          "marimo.eggID": page_num + 1,
          "marimo.id": id,
          "marimo.time": current_time + 1,
          "marimo.marimoList": marimoList,
          "marimo.marimoPartsNumMap": marimoPartsNumMap,
          "marimo.time_interval": time_interval,
          "marimo.marimoPartCheck": marimoPartCheck,
          "marimo.environmentTime": getx.environmentTime.value,
        };

        if (used_item != -1) {
          final item_amount = (await db.collection(getUserCollectionName(getx.mode))
              .doc(getx.walletAddress.value).get()).data()?['items']?['${used_item}'] ?? 0;

          if (item_amount < 1) {
            throw Error();
          }
          getx.environmentLevel.value = getx.environmentLevel.value + initial_data["environment_initial"];
          getx.healthLevel.value = initial_data["health_initial"];

          updateData["items.${used_item}"] = firestore.FieldValue.increment(-1);
          updateData["marimo.itemID"] = used_item;
          updateData["marimo.health"] = getx.healthLevel.value;
          updateData["environmentLevel"] = getx.environmentLevel.value;
        }
        await updateUserDB(db, updateData, false);
      } else {
        getx.healthLevel.value = initial_data["health_initial"];
      }
      return Future.value({
        "type": "awake_egg",
        "result": "success",
        "used_item": used_item,
      });
    } catch (e) {
      return Future.value({
        "type": "awake_egg",
        "error_message": 'execution reverted: KIP37: insufficient balance for transfer',
        "result": "error"
      });
    }
  }

  // 환경 상태에 따라 환경
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

  //
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

  // 타이머를 사용하여 주기적으로 알 부화 상태를 체크하고, 특정 조건에 따라 건강 상태와 환경 수준을 업데이트하며, 데이터를 데이터베이스에 저장하는 작업을 수행
  void startIncubating() async {
    isRunning = true; /* 부화 프로세스 실행 중 */
    incubatorTimer = Timer.periodic(Duration(seconds: 1), (timer) async { /* 1초마다 실행되는 주기적인 타이머 설정 */
      if (current_time <= time_interval) { /* 부화가 미완료 상태일 경우 부화 과정 진행. */
        if (controller.eggAwake && current_time > 3) { /* 알이 깨어난 상태를 4초 후 */
          controller.setEggAwake = false; // set eggAwake to false after 4 second
        }

        // edit health level
        // 60초마다 건강 수준을 업데이트
        health_plus_time++;
        if (health_plus_time >= 60) {
          getx.healthLevel.value += getHealthPlusCount();
          health_plus_time = 0;
        }

        final saveToDB = getMarimoParts(current_time); // make marimo parts
        controller.setMarimoGage(page_num, time_interval, current_time.toDouble());

        if (saveToDB) { /* saveToDB가 true일 때 marimo 데이터를 사용자 데이터베이스에 저장 */
          await saveMarimoData();
        }
      } else { /* 부화가 완료된 상태(current_time > time_interval)일 경우 */
        if (controller.isPlaying) {
          controller.setIsPlaying = false; /* 부화 상태 false로 설정 */
          controller.setIsIncubatorDone = true; /* 파츠 성장 완료 상태 */
          await saveMarimoData(); /* marimo 데이터를 사용자 데이터베이스에 저장 */
        }

        if (!controller.isPlaying && /* 부화가 완료된 상태인지 */
            controller.isIncubatorDone && /* 파츠 성장 완료 상태가 true일 경우  */
            controller.checkMintingStream == null) { /* 스트림 업데이트가 설정되지 않았는지 확인 */
          final String docID =
              sha256.convert(utf8.encode(marimoList.toString())).toString(); /* marimoList의 문자열을 SHA-256 해시 함수로 해싱하여 고유 문서 ID를 생성 */
          controller.checkMintingStream = db /* 생성한 docID를 사용하여 문서 snapshots 스트림을 설정 */
              .collection(getx.mode == "abis" ? "nft" : "nft_test")
              .doc(docID)
              .snapshots()
              .listen((event) {
            controller.setIsAbleMint(!event.exists); /* 민팅 가능 여부를 가능 상태로 설정*/
          });

          controller.emotionAudioController
              .openAudioPlayer(url: 'assets/sound/emotion_imoticon.mp3');
        }
      }

      // 환경 수준 업데이트
      environmentPlusTime++;
      if (environmentPlusTime >= 60) { /* 환경 수준이 60초 지날 경우 */
        getx.environmentLevel.value =
            min(getx.environmentLevel.value + environment_plus_count, 600); /* 환경게이지 값에 600을 넘지 않는 값을 저장 */
        environmentPlusTime = 0; /* 0으로 초기화 */
      }

      current_time++; /* 현재 시간 증가 */
    });
  }

  // 부화 과정의 진행 상태를 복원하고, 중지된 동안의 시간을 반영하여 건강 레벨과 환경 레벨을 업데이트한 후 부화 과정을 다시 시작
  void resumeIncubating(int diffTime) async {
    final remain_time = max(time_interval - current_time, 0); /* 남은 시간은 0보다 작지 않는다. */
    current_time += diffTime; /* 현재 시간 갱신 */

    if (controller.eggAwake && current_time > 3) { /* 부화한 상태의 알이 현재 기간 3초 시간 경과할 경우 알이 깨어 있는 상태를 false로 설정 */
      controller.setEggAwake = false; // set eggAwake to false after 4 second
    }

    // set main timer
    getx.environmentTime.value += min(diffTime, remain_time); /* 환경 시간 = min((현재시간-마지막사용시간), 남은 시간) */

    health_plus_time += min(diffTime, remain_time); /* 건강도 추가 시킬 시간 = min((현재시간-마지막사용시간), 남은 시간) */
    if (health_plus_time >= 60) { /* 건강도 추가 시킬 시간이 60초가 넘을 경우 넘은 만큼 해당 시간 동안 건강 레벨에 추가 => 이 작업을 해주는 이유가 ?? */
      for (int i = 0; i < (health_plus_time ~/ 60); i++) {
        getx.healthLevel.value += getHealthPlusCount();
      }
      health_plus_time = health_plus_time % 60;
    }

    // Marimo 부품 생성 및 게이지 설정
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

  // marimo 데이터를 사용자 데이터베이스에 저장
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

  // 현재 진행 중인 부화 과정을 일시 중지하는 기능
  void pauseIncubating() {
    isRunning = false; /* 부화 과정 중지 */
    incubatorTimer.cancel(); /* 타이머가 주기적으로 실행하지 않도록 설정 */
  }

  String getID() {
    return id;
  }
}
