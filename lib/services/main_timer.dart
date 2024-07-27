import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:ntp/ntp.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/services/service_functions.dart';

class mainTimer {
  late final FirebaseFirestore db;
  late final Timer timer;
  String lastDay = "";
  bool startTimer = false;

  // woodbox timer
  bool needToUpdateWoodbox = false;
  final RxInt woodboxCount = 0.obs;
  final RxString woodboxText = "".obs;

  // continue timer
  bool needToUpdateContinue = false;
  final RxInt delayCount = 0.obs;

  // daily mission timer
  bool needToUpdateMission = false;

  mainTimer(FirebaseFirestore firestore) {
    db = firestore;

    timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (startTimer) {
        DateTime currentTime = await NTP.now();
        final String currentDay = getTimeStamp(currentTime);

        if (checkDay(currentDay) || needToUpdateWoodbox) {
          woodboxCount.value = checkWoodBox(currentDay);
          if (woodboxCount.value == 0) {
            woodboxText.value = "내일 보상획득 가능";
          } else {
            woodboxText.value = "광고보고 상자 열기 (${woodboxCount.value}/5)";
          }
          needToUpdateWoodbox = false;
        }

        if (checkDay(currentDay) || needToUpdateContinue) {
          delayCount.value = checkContinueCount(currentDay);
          needToUpdateContinue = false;
        }

        if (checkDay(currentDay) || needToUpdateMission) {
          checkMission(currentDay);
          needToUpdateMission = false;
        }

        lastDay = currentDay;
      }
    });
  }

  Future<void> updateAll() async {
    startTimer = true;
    needToUpdateWoodbox = true;
    needToUpdateContinue = true;
    needToUpdateMission = true;
  }

  String getTimeStamp(DateTime currentTime) {
    String result = currentTime.toUtc().add(Duration(hours: 9)).year.toString();
    result += getFormatedString("0" + currentTime.toUtc().add(Duration(hours: 9)).month.toString());
    result += getFormatedString("0" + currentTime.toUtc().add(Duration(hours: 9)).day.toString());

    return result;
  }

  String getFormatedString(String s) {
    return s.substring(s.length - 2);
  }

  bool checkDay(String currentDay) {
    if (currentDay == lastDay) {
      return false;
    }

    return true;
  }

  // 현재 시간을 기준으로 사용자가 나무 상자를 열 수 있는지 확인.
  int checkWoodBox(String currentTime) {
    for (int i = 0; i < getx.woodBoxTime.value.length; i++) {
      if (getx.woodBoxTime.value[i] == currentTime) { /* 나무 상자를 열수 있는 시간 == 현재 시간 일 경우*/
        getx.woodBoxTime.value = getx.woodBoxTime.value.sublist(i); /* 해당 항목 이후의 모든 항목을 유지하는 하위 리스트로 업데이트 */
        db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({ /* 사용자가 나무 상자를 열은 시간을 기록 */
          "woodBoxTime": getx.woodBoxTime.value
        });

        return (5 - getx.woodBoxTime.value.length); /* 남은 보상 횟수 반환 */
      }
    }

    // 만약 현재 시간과 나무 상자를 열 수 있는 시간이 일치한 경우가 없을 경우
    getx.woodBoxTime.value = []; /* 빈 리스트로 초기화 */
    db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
      "woodBoxTime": getx.woodBoxTime.value
    });

    return 5; /* 보상 횟수를 5로 반환 */
  }

  // 현재 시간을 나무 상자 시간 리스트에 추가 및 보상 상태를 업데이트하도록 플래그를 설정.
  Future<void> updateWoodBox() async {
    DateTime currentTime = await NTP.now();
    getx.woodBoxTime.value.add(getTimeStamp(currentTime)); /* 현재 시간을 나무 상자 시간 리스트에 추가 */
    needToUpdateWoodbox = true; /* 보상 상태를 업데이트하도록 플래그를 설정 */
  }

  // 현재 시간을 기준으로 사용자가 연속적으로 활동한 횟수를 확인
  int checkContinueCount(String currentTime) {
    for (int i = 0; i < getx.continueTime.value.length; i++) {
      if (getx.continueTime.value[i] == currentTime) {
        getx.continueTime.value = getx.continueTime.value.sublist(i);
        db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({ /* 사용자가 연속적으로 활동한 시간을 기록 */
          "continueTime": getx.continueTime.value
        });

        return (3 - getx.continueTime.value.length); /* 남은 연속 활동 횟수를 반환 */
      }
    }

    // 만약 현재 시간과 사용자가 연속적으로 활동한 시간이 일치한 경우가 없을 경우
    getx.continueTime.value = []; /* 빈 리스트로 초기화 */
    db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
      "continueTime": getx.continueTime.value
    });

    return 3; /* 남은 연속 활동 시간을 3으로 반환 */
  }

  // 현재 시간을 연속 활동 시간 리스트에 추가하고 연속 활동 상태를 업데이트하도록 플래그를 설정
  Future<void> updateContinue() async {
    DateTime currentTime = await NTP.now();
    getx.continueTime.value.add(getTimeStamp(currentTime)); /* 현재 시간을 연속 활동 시간 리스트에 추가 */
    needToUpdateContinue = true; /* 연속 활동 상태를 업데이트하도록 플래그를 설정 */
  }

  Future<void> checkMission(String currentTime) async {
    for (var mission in getx.missionViewController.missions) {
      final String id = mission["mission_type"] + mission["id"].toString();
      if (getx.getReward.value[id] != null) {
        if (getx.getReward.value[id]["time"] == currentTime) {
          mission["isGetRewards"] = getx.getReward.value[id]["isGetRewards"];
          mission["complete_count"] = min<int>(getx.getReward.value[id]["count"], mission["complete_max_count"]);
        }
      }
    }

    await getx.missionViewController.getMissions();
  }

  Future<void> updateMissionCount(String id) async {
    if (getx.getReward.value[id] == null || getx.getReward.value[id]["time"] != lastDay) {
      getx.getReward.value[id] = {
        "time": lastDay,
        "isGetRewards": false,
        "count": 1,
      };
      db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
        "getReward.$id": getx.getReward.value[id]
      });
    } else {
      getx.getReward.value[id]["count"] += 1;
      db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
        "getReward.$id.count": FieldValue.increment(1)
      });
    }

    needToUpdateMission = true;
  }

  Future<void> getRewardMission(String id) async {
    getx.getReward.value[id]["isGetRewards"] = true;
    db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
      "getReward.$id.isGetRewards": true
    });

    needToUpdateMission = true;
  }
}