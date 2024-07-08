import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/collecting/collecting_view_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class CollectingPageCollectingView extends StatelessWidget {
  const CollectingPageCollectingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distanceOfWidget = 15.0;

    return Column(
      children: [
        CollectingInfo(),
        SizedBox(
          height: distanceOfWidget,
        ),
        CollectingTitle(),
        SizedBox(
          height: distanceOfWidget,
        ),
        CollectingOptionInfo(),
        SizedBox(
          height: distanceOfWidget,
        ),
        CollectingList(),
      ],
    );
  }
}

class CollectingInfo extends StatelessWidget {
  const CollectingInfo({Key? key}) : super(key: key);

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
          text:
              TextSpan(text: '콜렉팅 미션을 통해 ', style: normalTextStyle, children: [
            TextSpan(text: '추가 보상', style: pointTextStyle),
            TextSpan(text: '을 받을 수 있습니다.', style: normalTextStyle)
          ]),
        ),
      ],
    );
  }
}

class CollectingTitle extends StatelessWidget {
  CollectingTitle({
    Key? key,
  }) : super(key: key);

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
                    '콜렉팅 미션',
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

class CollectingOptionInfo extends StatelessWidget {
  const CollectingOptionInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collectingViewController = Get.find<CollectingViewController>();
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
          text:
              TextSpan(text: '현재 적용 옵션 : ', style: normalTextStyle, children: [
            TextSpan(
                text: collectingViewController.showSelectedOptions(),
                style: pointTextStyle),
          ]),
        ),
      ],
    );
  }
}

class CollectingList extends StatelessWidget {
  const CollectingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collectingViewController = Get.find<CollectingViewController>();
    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: collectingViewController.collectingModels.length,
        itemBuilder: (context, i) => CollectionBox(
          title: collectingViewController.collectingModels[i].title,
          content: collectingViewController.collectingModels[i].content,
          rewards:
              collectingViewController.collectingModels[i].rewards.join("\n"),
          require: collectingViewController.collectingModels[i].require,
          completeConditionCount: collectingViewController.collectingModels[i].current,
        ),
        separatorBuilder: (context, i) => SizedBox(
          height: 10,
        ),
      ),
    );
  }
}

class CollectionBox extends StatelessWidget {
  final String title;
  final String content;
  final String rewards;
  final int completeConditionCount;
  final int require;

  const CollectionBox(
      {Key? key,
      required this.title,
      required this.content,
      required this.rewards,
      required this.completeConditionCount,
      required this.require})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (title == '') {
      final titleTextStyle = TextStyle(
        fontSize: 16,
        fontFamily: 'ONE_Mobile_POP_OTF',
        color: Colors.white,
      );

      return Container(
          height: 80,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: HexColor('#62674E'),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Coming soon',
                style: titleTextStyle,
              ),
              Image.asset(
                'assets/lock.png',
                height: 40,
              )
            ],
          ));
    }

    final titleTextStyle = TextStyle(
      fontSize: 16,
      fontFamily: 'ONE_Mobile_POP_OTF',
      color: HexColor('#62674E'),
    );
    final contentTextStyle = TextStyle(
      fontSize: 10,
      fontFamily: 'ONE_Mobile_POP_OTF',
      height: 1.3,
      color: HexColor('#62674E'),
    );

    return Container(
      height: 80,
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            content,
                            style: contentTextStyle,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 3),
                        child: Stack(
                          children: [
                            LinearProgressIndicator(
                              minHeight: 15,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  HexColor("#FC8970")),
                              value: completeConditionCount / require,
                            ),
                            Container(
                                alignment: Alignment.center,
                                child: Text(
                                    '$completeConditionCount / ${require}',
                                    style: TextStyle(
                                      fontFamily: 'ONE_Mobile_POP_OTF',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: completeConditionCount == require
                                          ? HexColor('#555D42')
                                          : HexColor('#E5E5E5'),
                                    )))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: completeConditionCount == require
                                ? HexColor('#62674E')
                                : HexColor('#F4FBEE'),
                            border: Border.all(
                                width: 3, color: HexColor('#62674E')),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          rewards,
                          style: completeConditionCount == require
                              ? contentTextStyle.copyWith(
                                  color: Colors.white, fontSize: 9)
                              : contentTextStyle.copyWith(fontSize: 9),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
