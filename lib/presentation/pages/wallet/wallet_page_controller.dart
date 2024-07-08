import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class WalletPageController extends GetxController {
  /// 클레이 수량
  final _klay = 12.6.obs;
  double get klay => _klay.value;

  /// 개구니즈 토큰 수량
  final _ggnz = 13.7.obs;
  double get ggnz => _ggnz.value;

  /// 앱 내 바이트 토큰
  final _bait = 12.8.obs;
  double get bait => _bait.value;

  addBaitToken(double bait) {
    _bait.value = _bait.value + bait;
  }

  substractBaitToken(double bait) {
    _bait.value = _bait.value - bait;
  }

  void copyClipBorad(s) {
    Clipboard.setData(ClipboardData(text: s));
    Get.snackbar('${Get.arguments}', '',
        padding:
        const EdgeInsets.fromLTRB(10, 30, 10, 10),
        backgroundColor:
        HexColor('#2E0C0C').withOpacity(0.7),
        duration: const Duration(seconds: 2),
        titleText: Center(
            child: Text("copy_address".tr,
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ))));
  }
}
