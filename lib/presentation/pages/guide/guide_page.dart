import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/guide/guide_page_controller.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page_controller.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final guidePageController = Get.find<GuidePageController>();
    final controller = Get.find<IncubatorPageController>();

    return WillPopScope(
      onWillPop: () async {
        guidePageController.setIsSeenGuide();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          title: Text('olchaeneez_guide'.tr, /* 'olchaeneez_guide': '올채니즈 성장 가이드' */
              style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
          centerTitle: true,
          leading: InkWell(
              onTap: () {
                guidePageController.setIsSeenGuide(); /* 올체니즈 성장 가이드 한번 표시 되었음을 기록 */
              },
              child: const Center(
                  child: Icon(Icons.arrow_back_ios, color: Colors.black))),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(controller.backgroundStateImage),
              ),
            ),
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: PageView(
                children: [
                  //Image.asset('assets/guide3.png'),
                  Image.asset('assets/guide4.png'),
                  Image.asset('assets/guide0.png'),
                  Image.asset('assets/guide1.png'),
                  Image.asset('assets/guide2.png')
                ],
              ),
            )
        ),
      ),
    );
  }
}
