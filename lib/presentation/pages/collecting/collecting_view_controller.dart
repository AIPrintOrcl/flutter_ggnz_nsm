import 'package:get/get.dart';
import 'dart:math';
import 'package:ggnz/utils/getx_controller.dart';

class CollectingViewController extends GetxController {
  String showSelectedOptions() {
    return getRewardsList(getx.collectingReward).join(" ");
  }

  final collectings = [
    {'title': '', 'content': '', "require": 1, "current": 1, "rewards": []},
  ].obs;

  RxList<CollectingModel> _collectingModels = RxList<CollectingModel>([]);
  List<CollectingModel> get collectingModels => _collectingModels;

  getCollectings() {
    _collectingModels.value = collectings
        .map((element) => CollectingModel.fromJson(element))
        .toList();
  }

  int calculateCompleteContionCount({required List<String> condition}) {
    if (condition.isEmpty) {
      return 0;
    }
    final completeContionCount = condition.where((e) => e == 'true').length;
    return completeContionCount;
  }

  @override
  void onInit() {
    getCollectings();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  int getRequire(mission) {
    num tempRequire = 0;
    for (var m in mission) {
      if (["GOG", "GOP", "OCNZ"].contains(m["require"])) {
        tempRequire += m["amount"];
      } else if (m["require"] == "health") {
        tempRequire += 1;
      } else if (m["require"] == "item") {
        if (m["type"] == "sum") {
          tempRequire += m["amount"];
        } else {
          for (var i in m["amount"]) {
            tempRequire += i;
          }
        }
      }
    }

    return tempRequire.toInt();
  }

  int getCurrent(mission) {
    num tempCurrent = 0;
    for (var m in mission) {
      if (m["require"] == "GOG") {
        tempCurrent += min(m["amount"], getx.gog.value);
      } else if (m["require"] == "GOP") {
        tempCurrent += min(m["amount"], getx.gop.value);
      } else if (m["require"] == "OCNZ") {
        tempCurrent += min(m["amount"], getx.ocnz.value);
      } else if (m["require"] == "health") {
        if (m["type"] == "over") {
          for (var h in getx.ocnzInfo.values) {
            if (h >= m["amount"]) {
              tempCurrent += 1;
              break;
            }
          }
        } else if (m["type"] == "under") {
          for (var h in getx.ocnzInfo.values) {
            if (h <= m["amount"]) {
              tempCurrent += 1;
              break;
            }
          }
        }
      } else if (m["require"] == "item") {
        if (m["type"] == "sum") {
          int total_used = 0;
          for (var id in m["id"]) {
            total_used += getx.getItemUsedCount(id.toString());
          }
          tempCurrent += min(m["amount"], total_used);
        } else {
          for (var i = 0; i < m["id"].length; i++) {
            tempCurrent += min(m["amount"][i], getx.getItemUsedCount(m["id"][i].toString()));
          }
        }
      }
    }

    return tempCurrent.toInt();
  }

  List<String> getRewardsList(Map reward) {
    List<String> tempResult = [];

    reward.forEach((key, value) {
      if (key == "health") {
        tempResult.add("건강도 증가 ${value}%");
      } else if (key == "environment") {
        tempResult.add("환경도 증가 ${value}%");
      }
    });

    return tempResult;
  }
}

class CollectingModel {
  CollectingModel({
    required this.title,
    required this.content,
    required this.require,
    required this.current,
    required this.rewards,
  });

  String title;
  String content;
  int require;
  int current;
  List<String> rewards;

  factory CollectingModel.fromJson(Map<String, dynamic> json) =>
      CollectingModel(
        title: json["title"],
        content: json["content"],
        require: json["require"],
        current: json["current"],
        rewards: List<String>.from(json["rewards"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "content": content,
        "require": require,
        "current": current,
        "rewards": List<dynamic>.from(rewards.map((x) => x)),
      };
}
