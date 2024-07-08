import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/collecting/mission_view_controller.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';
import 'package:ggnz/presentation/pages/wallet/sign_wallet_page.dart';
import 'package:hexcolor/hexcolor.dart';

class CollectingPageMissionView extends StatelessWidget {
  const CollectingPageMissionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distanceOfWidget = 15.0;

    return Column(
      children: [
        MissionInfo(),
        SizedBox(
          height: distanceOfWidget,
        ),
        MissionTitle(title: '일일 미션'),
        SizedBox(
          height: distanceOfWidget,
        ),
        MissionList(
          mission_type: MissionType.Daily.name,
        ),
        SizedBox(
          height: distanceOfWidget,
        ),
        MissionTitle(title: '주간 미션'),
        SizedBox(
          height: distanceOfWidget,
        ),
        MissionList(
          mission_type: MissionType.Weekly.name,
        ),
      ],
    );
  }
}

class MissionInfo extends StatelessWidget {
  const MissionInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final normalTextStyle = TextStyle(
      fontSize: 12,
      fontFamily: 'ONE_Mobile_POP_OTF',
      color: HexColor("#A5AA8E"),
    );

    final pointTextStyle = TextStyle(
      fontSize: 12,
      fontFamily: 'ONE_Mobile_POP_OTF',
      color: HexColor('#62674E'),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
              text: '주간 / 일일 미션을 통해 ',
              style: normalTextStyle,
              children: [
                TextSpan(text: '추가 보상', style: pointTextStyle),
                TextSpan(text: '을 받을 수 있습니다.', style: normalTextStyle)
              ]),
        ),
      ],
    );
  }
}

class MissionTitle extends StatelessWidget {
  final title;
  MissionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dotStyle = TextStyle(
        fontSize: 5,
        fontWeight: FontWeight.bold,
        fontFamily: 'ONE_Mobile_POP_OTF',
        color: HexColor('#E5EBDE'));

    final titleStyle = TextStyle(
        fontSize: 18, fontFamily: 'ONE_Mobile_POP_OTF', color: Colors.white);

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
        child: Row(
          children: List.generate(
              150 ~/ 10,
              (index) => Expanded(
                    child: Container(
                      color: index % 2 == 0
                          ? Colors.transparent
                          : HexColor('#A5AA8E'),
                      height: 2,
                    ),
                  )),
        ),
      ),
      Expanded(
          flex: 2,
          child: Container(
              decoration: BoxDecoration(
                  color: HexColor('#A5AA8E'),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '●',
                    style: dotStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    title,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '●',
                    style: dotStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ))),
      Expanded(
        child: Row(
          children: List.generate(
              150 ~/ 10,
              (index) => Expanded(
                    child: Container(
                      color: index % 2 == 0
                          ? Colors.transparent
                          : HexColor('#A5AA8E'),
                      height: 2,
                    ),
                  )),
        ),
      ),
    ]);
  }
}

class MissionList extends StatelessWidget {
  final mission_type;
  const MissionList({Key? key, required this.mission_type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final missionViewController = Get.find<MissionViewController>();

    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: missionViewController.missionModels.length,
        itemBuilder: (context, i) => mission_type !=
                missionViewController.missionModels[i].mission_type
            ? Container()
            : MissionBox(
                title: missionViewController.missionModels[i].content,
                type: missionViewController.missionModels[i].missionText(),
                rewards:
                    missionViewController.missionModels[i].rewards.join("\n"),
                rewards_id: missionViewController.missionModels[i].rewards_id,
                complete_max_count:
                    missionViewController.missionModels[i].complete_max_count,
                complete_count:
                    missionViewController.missionModels[i].complete_count,
                rewards_image:
                    missionViewController.missionModels[i].rewards_image,
                isGetRewards:
                    missionViewController.missionModels[i].isGetRewards,
              ),
        separatorBuilder: (context, i) =>
            mission_type != missionViewController.missionModels[i].mission_type
                ? Container()
                : SizedBox(
                    height: 5,
                  ),
      ),
    );
  }
}

class MissionBox extends StatelessWidget {
  final String title;
  final String type;
  final num complete_max_count;
  final num complete_count;
  final String rewards;
  final List<int> rewards_id;
  final String rewards_image;
  final bool isGetRewards;

  const MissionBox(
      {Key? key,
      required this.title,
      required this.type,
      required this.complete_max_count,
      required this.complete_count,
      required this.rewards,
      required this.rewards_id,
      required this.rewards_image,
      required this.isGetRewards})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final missionViewController = Get.find<MissionViewController>();
    final incubatorController = Get.find<IncubatorPageController>();
    final titleTextStyle = TextStyle(
      fontSize: 13,
      fontFamily: 'ONE_Mobile_POP_OTF',
      color: HexColor('#62674E'),
    );

    final missionCountTextStyle = TextStyle(
      fontFamily: 'ONE_Mobile_POP_OTF',
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: complete_count >= complete_max_count
          ? HexColor('#555D42')
          : HexColor('#E5E5E5'),
    );

    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: HexColor('#F4FBEE'),
          border: Border.all(width: 3, color: HexColor('#62674E')),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: titleTextStyle,
                          )
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        LinearProgressIndicator(
                          minHeight: 10,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              HexColor("#FC8970")),
                          value: complete_count == 0
                              ? 0
                              : complete_max_count > 3600
                                  ? complete_count / complete_max_count
                                  : complete_count / complete_max_count,
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: complete_max_count > 3600
                                ? Text(
                                    missionViewController.convertIntToTime(
                                        hour: complete_count),
                                    style: missionCountTextStyle)
                                : Text('$complete_count / $complete_max_count',
                                    style: missionCountTextStyle))
                      ],
                    ),
                  ],
                ),
              )),
          Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (complete_count >= complete_max_count && !isGetRewards) {
                          final result = await Get.to(() => SignWalletPage(signReason: 'get_rewards'.tr),
                              arguments: {"reason": "get_rewards"});

                          if (result) {
                            incubatorController.getMissionRewards(rewards_id, type);
                          }
                        }
                      },
                      child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: isGetRewards
                                  ? Colors.grey
                                  : complete_count >= complete_max_count
                                  ? HexColor('#A5AA8E')
                                  : HexColor('#F4FBEE'),
                              border: Border.all(
                                  width: 3,
                                  color: isGetRewards
                                      ? Colors.grey
                                      : HexColor('#A5AA8E')),
                              borderRadius: BorderRadius.circular(10)),
                          child: Image.asset(
                            rewards_image,
                            color: isGetRewards ? Colors.grey : null,
                            colorBlendMode: BlendMode.saturation,
                          )),
                    )
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
