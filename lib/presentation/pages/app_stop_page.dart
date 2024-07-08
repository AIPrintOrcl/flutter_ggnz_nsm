import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/widgets/buttons/button_sound.dart';
import 'package:ggnz/utils/const.dart';
import 'package:hexcolor/hexcolor.dart';

class AppStopPage extends StatelessWidget {
  const AppStopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStopPageController = Get.put(AppStopPageController());
    return Scaffold(
      body: Obx(
        () => Container(
          height: Get.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: AssetImage('assets/bg0.gif'))),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/notice_paper_with_text.png',
                fit: BoxFit.cover,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 70),
                decoration: BoxDecoration(border: Border.all(width: 2)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '< ${appStopPageController.title} >',
                      style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: appStopPageController.textColor.isEmpty
                              ? Colors.green.shade400
                              : HexColor(appStopPageController.textColor),
                          fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      appStopPageController.subtitle,
                      style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: appStopPageController.textColor.isEmpty
                              ? Colors.green.shade400
                              : HexColor(appStopPageController.textColor),
                          fontSize: 18),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      appStopPageController.mainText,
                      style: TextStyle(
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          color: appStopPageController.textColor.isEmpty
                              ? Colors.green.shade400
                              : HexColor(appStopPageController.textColor),
                          fontSize: 15),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppStopPageController extends GetxController {
  final _title = ''.obs;
  String get title => _title.value;
  final _subtitle = ''.obs;
  String get subtitle => _subtitle.value;
  final _mainText = ''.obs;
  String get mainText => _mainText.value;
  final _textColor = ''.obs;
  String get textColor => _textColor.value;

  void _checkFirebaseFireStore() {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection(CONFIG);
    docRef.snapshots().listen(
      (event) {
        _title.value = event.docs.first['title'];
        _subtitle.value = event.docs.first['subtitle'];
        _mainText.value = (event.docs.first['maintext'] as String).replaceAll("\\n", "\n");
        _textColor.value = event.docs.first['textcolor'];
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  @override
  void onInit() {
    _checkFirebaseFireStore();
    super.onInit();
  }
}
