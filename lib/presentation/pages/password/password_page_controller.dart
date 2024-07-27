import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page.dart';
import 'package:ggnz/presentation/pages/incubator/pre_incubator_page.dart';
import 'package:ggnz/web3dart/credentials.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/web3dart/crypto.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/service_functions.dart';
import '../../../utils/utility_function.dart';

class PasswordPageController extends GetxController {
  var first = true;
  // 비밀번호 주의사항 체크
  final _isClicked = false.obs;
  bool get isClicked => _isClicked.value;
  set setIsClicked(bool value) => _isClicked.value = value;


  final _walletAddress = "".obs;
  String get walletAddress => _walletAddress.value;
  set setWalletAddress(String value) => _walletAddress.value = value;

  final _isFirstPasswordDone = false.obs;
  bool get isFirstPasswordDone => _isFirstPasswordDone.value;

  late final bool isUserIdExist;

  final _keyPadNums = [
    ["2", "6", "4"],
    ["9", "5", "7"],
    ["3", "1", "8"],
    ['reset', "0", "<"]
  ].obs;
  List<List<dynamic>> get keyPadNums => _keyPadNums;

  final _passWord = "".obs;
  String get passWord => _passWord.value;

  final _confirmPassWord = "".obs;
  String get confirmPassWord => _confirmPassWord.value;

  final _recordPassWord = "".obs;
  String get recordPassWord => _recordPassWord.value;

  bool get isConfirmPassWord => _recordPassWord.value.length == 6;

  setKeyPadNums(String value) {
    if (_passWord.value.length == 6 || value == 'reset' || value == "<") { /* 6자리 이상 || 리셋 버튼 || 벡스페이스 입력 */
      return;
    }
    for (var x in _keyPadNums) { /* 리스트 키패드숫자가 0이 포함되지 않을 경우 해당 리스트를 섞는다. */
      if (!x.contains("0")) {
        x.shuffle();
      }
    }
    // _keyPadNums.shuffle();
  }

  // 패스워드 입력 및 확인
  setPassWord(String value) async {
    if (value != "<" && _passWord.value.length < 6 && value != 'reset') {
      _passWord.value = _passWord.value + value;
    }

    if (value == 'reset') {
      _passWord.value = "";
    }

    if (value == "<") {
      if (_passWord.value.isEmpty) {
        return;
      }
      _passWord.value =
          _passWord.value.substring(0, _passWord.value.length - 1);
    }

    if (_passWord.value.length == 6) {
      //check password with existing keystore file
      if (isUserIdExist || Get.arguments != null && Get.arguments["key"] != null) {
        try {
          var resultCount = await getx.db.collection(getUserCollectionName(getx.mode))
              .where(firestore.FieldPath.documentId, isEqualTo: getx.walletAddress.value == "" ? Get.arguments["key"] : getx.walletAddress.value)
              .where("pw", isEqualTo: _passWord.value)
              .count()
              .get();

          if (resultCount.count! < 1) {
            throw ArgumentError();
          }

          if (!isUserIdExist) {
            final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
            sharedPrefs.setString('userId', Get.arguments["key"]);
            getx.walletAddress.value = Get.arguments["key"];
          }

          Get.off(() => const IncubatorPage(),
            transition: Transition.fadeIn,

          );
          return;
        } on ArgumentError {
          if (!Get.isSnackbarOpen) {
            Get.snackbar('비밀번호가 일치하지 않습니다.', '', duration: Duration(seconds: 1));
          }
          _passWord.value = "";
          return;
        }
      } else {
        _isFirstPasswordDone.value = true;
        _recordPassWord.value = _passWord.value;
        _passWord.value = "";
      }
    }
  }

  // 사용자가 입력한 비밀번호를 확인하고, 일치하면 새로운 지갑을 생성하고 초기 설정을 진행합니다. 일치하지 않으면 스낵바를 통해 사용자에게 알림을 제공
  setConfirmPassWord(String value) async {
    if (value != "<" && _confirmPassWord.value.length < 6 && value != 'reset') { /* if 조건 제외 시 입력 된다. */
      _confirmPassWord.value = _confirmPassWord.value + value;
    }

    if (value == 'reset') { // 리셋 클릭
      _confirmPassWord.value = "";
    }

    if (value == "<") { // 백 스페이스
      if (_confirmPassWord.value.isEmpty) { /* 문자열이 비어 있으면 리턴 */
        return;
      }
      _confirmPassWord.value = _confirmPassWord.value
          .substring(0, _confirmPassWord.value.length - 1);
    }

    if (_confirmPassWord.value.length == 6 &&
        _recordPassWord.value == _confirmPassWord.value && first) {
      first = false;

      // find exist user
      final tempDoc = await getx.db.collection(getUserCollectionName(getx.mode))
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid.toString())
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
          .get();

      late final userDoc;
      if (tempDoc.size == 0) {
        //create new userId
        userDoc = await getx.db.collection(getUserCollectionName(getx.mode)).doc();
        await userDoc.set({
          "pw": _confirmPassWord.value,
          'uid': FirebaseAuth.instance.currentUser?.uid.toString(),
          'email': FirebaseAuth.instance.currentUser?.email.toString()
        });
      } else {
        userDoc = await tempDoc.docs[0];
      }

      final userId = userDoc.id;
      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
      sharedPrefs.setString('uid', FirebaseAuth.instance.currentUser?.uid.toString() ?? '');
      sharedPrefs.setString('userId', userId);
      getx.walletAddress.value = userId;
      getx.uid.value = FirebaseAuth.instance.currentUser?.uid.toString() ?? '';
      setWalletAddress = userId;

      await updateUserDB(getx.db, {
        "pw": _confirmPassWord.value,
      }, false);

      await getx.getInitialValue();

      Get.off(() => const PreIncubatorPage(), /* 지갑 생성 완료 확인 페이지 이동. */
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500));
    }

    if (_confirmPassWord.value.length == 6 &&
        _recordPassWord.value != _confirmPassWord.value &&
        !Get.isSnackbarOpen) { /* 1차와 2차 비밀번호가 다를 경우 */
      Get.snackbar('password'.tr, 'password_check'.tr); /* 'password': '비밀번호', 'password_check': '입력하신 비밀번호를 확인해주세요' */
    }
  }

  @override
  void onInit() {
    isUserIdExist = getx.isUserIdExist;
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
