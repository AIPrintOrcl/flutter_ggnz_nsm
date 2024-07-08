import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/collecting/encyclopedia_view_controller.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:hexcolor/hexcolor.dart';

class CollectingPageEncyclopediaView extends StatelessWidget {
  const CollectingPageEncyclopediaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final encyclopediaController = Get.find<EncyclopediaViewController>();
    final distanceOfWidget = 25.0;

    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: distanceOfWidget,
          ),
          NftTitle(
            key: Key('GOG'),
            nftCount: getx.gog.value.toInt(),
            nftTitle: 'GOG',
            imageOpen: encyclopediaController.isGogOpen,
          ),
          SizedBox(
            height: distanceOfWidget,
          ),
          CollectingPageEncyclopediaGogView(),
          SizedBox(
            height: distanceOfWidget,
          ),
          NftTitle(
            key: Key('GOP'),
            nftCount: getx.gop.value.toInt(),
            nftTitle: 'GOP',
            imageOpen: encyclopediaController.isGopOpen,
          ),
          SizedBox(
            height: distanceOfWidget,
          ),
          CollectingPageEncyclopediaGopView(),
          SizedBox(
            height: distanceOfWidget,
          ),
          NftTitle(
            key: Key('OCNZ'),
            nftCount: getx.ocnz.value.toInt(),
            nftTitle: 'OCNZ',
            imageOpen: encyclopediaController.isOcnzOpen,
          ),
          SizedBox(
            height: distanceOfWidget,
          ),
          CollectingPageEncyclopediaOcnzView(),
        ],
      ),
    );
  }
}

class CollectingPageEncyclopediaGogView extends StatelessWidget {
  const CollectingPageEncyclopediaGogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final encyclopediaController = Get.find<EncyclopediaViewController>();
    return Obx(() {
      if (!encyclopediaController.isGogOpen || getx.gogImageUrls.isEmpty) {
        return Container();
      }
      return Expanded(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: getx.gogImageUrls.length,
          itemBuilder: (context, i) => EncyclopediaBox(
            imageUrl: getx.gogImageUrls[i],
          ),
          separatorBuilder: (context, i) => SizedBox(
            width: 10,
          ),
        ),
      );
    });
  }
}

class CollectingPageEncyclopediaGopView extends StatelessWidget {
  const CollectingPageEncyclopediaGopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final encyclopediaController = Get.find<EncyclopediaViewController>();
    return Obx(() {
      if (!encyclopediaController.isGopOpen || getx.gopImageUrls.isEmpty) {
        return Container();
      }
      return Expanded(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: getx.gopImageUrls.length,
          itemBuilder: (context, i) => EncyclopediaBox(
            imageUrl: getx.gopImageUrls[i],
          ),
          separatorBuilder: (context, i) => SizedBox(
            width: 10,
          ),
        ),
      );
    });
  }
}

class CollectingPageEncyclopediaOcnzView extends StatelessWidget {
  const CollectingPageEncyclopediaOcnzView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final encyclopediaController = Get.find<EncyclopediaViewController>();

    return Obx(() {
      if (!encyclopediaController.isOcnzOpen || getx.ocnzImageUrls.isEmpty) {
        return Container();
      }
      return Expanded(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: getx.ocnzImageUrls.length,
          itemBuilder: (context, i) => EncyclopediaBox(
            imageUrl: getx.ocnzImageUrls[i],
            health: getx.ocnzInfo[getx.ocnzImageUrls[i]],
          ),
          separatorBuilder: (context, i) => SizedBox(
            width: 10,
          ),
        ),
      );
    });
  }
}

class EncyclopediaBox extends StatelessWidget {
  final String imageUrl;
  final num? health;

  const EncyclopediaBox({Key? key, required this.imageUrl, this.health})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int? intHealth = health != null ? health!.toInt() : null;
    final healthTextStyle =
        TextStyle(fontFamily: 'ONE_Mobile_POP_OTF', color: Colors.white);
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 3, color: HexColor('#A5AA8E')),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Image.network(imageUrl, fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.green,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ));
              }),
              if (health != null)
                Positioned(
                  right: 5,
                  bottom: 2,
                  child: Text(
                    'HP : ${intHealth}',
                    style: healthTextStyle,
                  ),
                )
            ],
          ),
        ));
  }
}

class NftTitle extends StatelessWidget {
  final nftCount;
  final nftTitle;
  final imageOpen;
  NftTitle(
      {Key? key,
      required this.nftCount,
      required this.nftTitle,
      required this.imageOpen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final encyclopediaController = Get.find<EncyclopediaViewController>();
    final dotStyle = TextStyle(
        fontSize: 5,
        fontWeight: FontWeight.bold,
        fontFamily: 'ONE_Mobile_POP_OTF',
        color: HexColor('#E5EBDE'));

    final titleStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'ONE_Mobile_POP_OTF',
        color: Colors.white);

    final countStyle = TextStyle(
        fontSize: 15,
        fontFamily: 'ONE_Mobile_POP_OTF',
        color: HexColor('#A5AA8E'));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                        nftTitle,
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
        ]),
        Positioned(
          bottom: 5,
          right: 0,
          child: InkWell(
            onTap: () {
              if (nftCount > 0) {
                encyclopediaController.toggleNftOpen(nftTitle: nftTitle);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    if (nftCount > 0) {
                      encyclopediaController.toggleNftOpen(nftTitle: nftTitle);
                    }
                  },
                  child: Opacity(
                      opacity: nftCount > 0 ? 1 : 0,
                      child: imageOpen
                          ? Icon(
                              Icons.arrow_drop_up,
                              size: 40,
                              color: HexColor('#A5AA8E'),
                            )
                          : Icon(
                              Icons.arrow_drop_down,
                              size: 40,
                              color: HexColor('#A5AA8E'),
                            )),
                ),
                InkWell(
                  onTap: () {
                    if (nftCount > 0) {
                      encyclopediaController.toggleNftOpen(nftTitle: nftTitle);
                    }
                  },
                  child: Text(
                    '($nftCount)',
                    style: countStyle,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
