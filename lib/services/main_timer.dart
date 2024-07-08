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

  int checkWoodBox(String currentTime) {
    for (int i = 0; i < getx.woodBoxTime.value.length; i++) {
      if (getx.woodBoxTime.value[i] == currentTime) {
        getx.woodBoxTime.value = getx.woodBoxTime.value.sublist(i);
        db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
          "woodBoxTime": getx.woodBoxTime.value
        });

        return (5 - getx.woodBoxTime.value.length);
      }
    }

    getx.woodBoxTime.value = [];
    db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
      "woodBoxTime": getx.woodBoxTime.value
    });

    return 5;
  }

  Future<void> updateWoodBox() async {
    DateTime currentTime = await NTP.now();
    getx.woodBoxTime.value.add(getTimeStamp(currentTime));
    needToUpdateWoodbox = true;
  }

  int checkContinueCount(String currentTime) {
    for (int i = 0; i < getx.continueTime.value.length; i++) {
      if (getx.continueTime.value[i] == currentTime) {
        getx.continueTime.value = getx.continueTime.value.sublist(i);
        db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
          "continueTime": getx.continueTime.value
        });

        return (3 - getx.continueTime.value.length);
      }
    }

    getx.continueTime.value = [];
    db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
      "continueTime": getx.continueTime.value
    });

    return 3;
  }

  Future<void> updateContinue() async {
    DateTime currentTime = await NTP.now();
    getx.continueTime.value.add(getTimeStamp(currentTime));
    needToUpdateContinue = true;
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