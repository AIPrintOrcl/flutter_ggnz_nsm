import 'package:get/get.dart';

enum MissionType { Daily, Weekly }

class MissionViewController extends GetxController {
  List missions = [

  ].obs;

  RxList<MissionModel> _missionModels = RxList<MissionModel>([]);
  List<MissionModel> get missionModels => _missionModels;

  getMissions() {
    _missionModels.value =
        missions.map((element) => MissionModel.fromJson(element)).toList();
  }

  int getRequire(mission) {
    num tempRequire = 0;
    for (var m in mission) {
      if (["GOG", "GOP", "OCNZ"].contains(m["require"])) {
        tempRequire += m["amount"];
      } else if (m["require"] == "item") {
        tempRequire += m["amount"];
      } else if (m["require"] == "dispatch") {
        tempRequire += m["amount"];
      }
    }

    return tempRequire.toInt();
  }

  String getMissionType(String type) {
    if (type == "daily") {
      return MissionType.Daily.name;
    } else {
      return MissionType.Weekly.name;
    }
  }

  convertIntToTime({required num hour}) {
    if (hour > 21600) {
      return "06:00:00";
    }

    int value = hour.toInt();
    int h, m, s;

    h = value ~/ 3600;

    m = ((value - h * 3600)) ~/ 60;

    s = value - (h * 3600) - (m * 60);

    String hourLeft =
        h.toString().length < 2 ? "0" + h.toString() : h.toString();

    String minuteLeft =
        m.toString().length < 2 ? "0" + m.toString() : m.toString();

    String secondsLeft =
        s.toString().length < 2 ? "0" + s.toString() : s.toString();

    String result = "$hourLeft:$minuteLeft:$secondsLeft";

    return result;
  }

  @override
  void onInit() {
    getMissions();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}

class MissionModel {
  MissionModel(
      {required this.title,
      required this.content,
      required this.id,
      required this.complete_max_count,
      required this.complete_count,
      required this.mission_type,
      required this.rewards,
      required this.rewards_id,
      required this.rewards_image,
      required this.isGetRewards});

  String title;
  String content;
  int id;
  num complete_max_count;
  num complete_count;
  String mission_type;
  List<String> rewards;
  List<int> rewards_id;
  String rewards_image;
  bool isGetRewards;

  String missionText() {
    return mission_type + id.toString();
  }

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(
      title: json["title"],
      id: json["id"],
      content: json["content"],
      complete_max_count: json["complete_max_count"],
      complete_count: json["complete_count"],
      mission_type: json["mission_type"],
      rewards: List<String>.from(json["rewards"].map((x) => x)),
      rewards_id: List<int>.from(json["rewards_id"].map((x) => x)),
      rewards_image: json['rewards_image'],
      isGetRewards: json['isGetRewards']
  );

  Map<String, dynamic> toJson() => {
        "title": title,
        "id": id,
        "content": content,
        "complete_max_count": complete_max_count,
        "complete_count": complete_count,
        "mission_type": mission_type,
        "rewards": List<dynamic>.from(rewards.map((x) => x)),
        "rewards_id": rewards_id,
        'rewards_image': rewards_image,
        'isGetRewards': isGetRewards
      };
}
