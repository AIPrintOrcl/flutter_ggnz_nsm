import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ntp/ntp.dart';

Future<void> updateUserDB(FirebaseFirestore db, data, bool needTimer) async {
  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update(data);
}

Future<void> appendUserErrorDB(FirebaseFirestore db, Map<String, dynamic> data) async {
  DateTime currentTime = await NTP.now();
  print(data);
  data["time"] = currentTime.toUtc().add(Duration(hours: 9)).toString();
  data["timemillis"] = currentTime.millisecondsSinceEpoch;

  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value)
      .collection("error").add(data);
}

Future<String> adddataUserCollectionDB(FirebaseFirestore db, String collection_name, Map<String, dynamic> data, bool needTimer) async {
  late final String docID;

  if (needTimer) {
    DateTime currentTime = await NTP.now();
    data["time"] = currentTime.toUtc().add(Duration(hours: 9)).toString();
    data["timemillis"] = currentTime.millisecondsSinceEpoch;
  }

  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value)
      .collection(collection_name).add(data).then((value) => docID = value.id);

  return docID;
}

Future<void> updateUserCollectionDB(FirebaseFirestore db, String collection_name, String docID, data) async {
  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value)
      .collection(collection_name).doc(docID).update(data);
}

Future<String> getDeviceInfo() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final device_info = await deviceInfoPlugin.deviceInfo;

  if (Platform.isAndroid) {
    return device_info.data["id"].toString();
  } else if (Platform.isIOS) {
    return device_info.data["identifierForVendor"];
  }
  device_info.data.forEach((key, value) {
    print("index: " + key.toString() + ", value: " + value.toString());
  });

  return "no device info";
}

// return type
// 1: collection database are empty - make new database
// 2: collection is exist but device is not equal - cannot process dispatch
// 3: collection is exist and device is equal but dispatch is not finished. - need to continue dispatch
// 4: device is equal and dispatch is finished. - cannot process dispatch
Future<Map> canDispatchDevice(FirebaseFirestore db, String id, String mint_id) async  {
  Map result_data = {};

  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value)
      .collection("dispatch").where("id", isEqualTo: id).where("mint_id", isEqualTo: mint_id).limit(1).get().then((querySnapshot) {
        if (querySnapshot.docs.length != 0) {
          final doc = querySnapshot.docs[0];
          result_data["docID"] = doc.id;

          if (doc.data()["device"] != getx.deviceID.value) {
            result_data["result"] = 2;
          } else if (!doc.data()["finished"]) {
            result_data["result"] = 3;
          } else {
            result_data["result"] = 4;
          }
        } else {
          result_data["result"] = 1;
        }
  });

  return result_data;
}

String getSHA256(String s) {
  return sha256.convert(utf8.encode(s)).toString();
}

Future<void> checkErrorLength(FirebaseFirestore db) async {
  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).get().then((doc) async {
    final data = doc.data();
    if (data?["errorLogs"] != null) {
      final length = data?["errorLogs"].length;
      final limit_length = getx.mode == "abis"? 50 : 5;
      final sublist_length = getx.mode == "abis"? 30 : 3;

      if (length > limit_length) {
        await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
          "errorLogs": data?["errorLogs"].sublist(length - sublist_length)
        });
      }
    }
  });
}

void checkMarimoData(Map data, int time) {
  if (data["health"] == null) {
    data["health"] = 0;
  }
  if (data["time"] == null) {
    data["time"] = 0;
  }
  if (data["marimoList"] == null) {
    data["marimoList"] = List.generate(13, (index) => '');
  }
  if (data["marimoPartsNumMap"] == null) {
    Map<String, String> tempMap = {};
    data["marimoPartsNumMap"] = tempMap;
  }
  if (data["time_interval"] == null) {
    data["time_interval"] = time;
  }
  if (data["marimoPartCheck"] == null) {
    data["marimoPartCheck"] = [false, false, false, false];
  }
  if (data["environmentTime"] == null) {
    data["environmentTime"] = 0;
  }
}