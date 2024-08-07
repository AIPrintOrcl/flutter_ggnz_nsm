import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page.dart';
import 'package:ggnz/presentation/pages/incubator/pre_incubator_page.dart';
import 'package:ggnz/services/service_app_init.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:ggnz/web3dart/credentials.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/service_functions.dart';
import '../../../utils/utility_function.dart';

class PasswordPageController extends GetxController {
  var first = true;
  // 비밀번호 주의사항 체크
  final _isClicked = false.obs;
  bool get isClicked => _isClicked.value;
  set setIsClicked(bool value) => _isClicked.value = value;

  // 지갑 주소
  final _walletAddress = "".obs;
  String get walletAddress => _walletAddress.value;
  set setWalletAddress(String value) => _walletAddress.value = value;

  // 1/2차 비밀번호. 2차 비밀번호는 기존 등록된 유저가 비밀번호 입력할 때 사용.
  final _isFirstPasswordDone = false.obs;
  bool get isFirstPasswordDone => _isFirstPasswordDone.value;

  // 로그인한 유저 아이디 있는지 여부
  // late final bool isUserIdExist;
  var isUserIdExist;

  // 키패드에 세팅할 값을 List로 저장
  final _keyPadNums = [
    ["2", "6", "4"],
    ["9", "5", "7"],
    ["3", "1", "8"],
    ['reset', "0", "<"]
  ].obs;
  List<List<dynamic>> get keyPadNums => _keyPadNums;


  // 입력한 비밀번호 임시 저장하는 변수
  final _passWord = "".obs;
  String get passWord => _passWord.value;

  // 2차 비밀번호 저장된 변수
  final _confirmPassWord = "".obs;
  String get confirmPassWord => _confirmPassWord.value;

  // 1차 비밀번호 저장한 변수
  final _recordPassWord = "".obs;
  String get recordPassWord => _recordPassWord.value;

  // 1차 비밀번호 입력 후 확인을 위한 2차 비밀번호 입력 단계인지의 여부
  bool get isConfirmPassWord => _recordPassWord.value.length == 6;

  // get data from firestore
  final firestore.FirebaseFirestore db = firestore.FirebaseFirestore.instance;

  setKeyPadNums(String value) {
    if (_passWord.value.length == 6 || value == 'reset' || value == "<") { // 6자리 이상 || 리셋 버튼 || 벡스페이스 입력
      return;
    }
    for (var x in _keyPadNums) { // 리스트 키패드숫자가 0이 포함되지 않을 경우 해당 리스트를 섞는다.
      if (!x.contains("0")) {
        x.shuffle();
      }
    }
    // _keyPadNums.shuffle();
  }

  // 키패드로 입력한 비밀번호 set. 6자리 일 경우 입력한 비밀번호와 기존 저장소 파일에 등록된 비밀번호와 확인
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

    if (_passWord.value.length == 6) { // 입력한 비밀번호가 6자리 일 경우 기존 저장소 파일에 등록된 비밀번호와 확인
      //check password with existing keystore file 기존 키 저장소 파일로 비밀번호 확인
      if (isUserIdExist || Get.arguments != null && Get.arguments["key"] != null) { // 기존 등록된 유저일 경우
        try {
          var resultCount = await getx.db.collection(getUserCollectionName(getx.mode))
              .where(firestore.FieldPath.documentId, isEqualTo: getx.walletAddress.value == "" ? Get.arguments["key"] : getx.walletAddress.value)
              .where("pw", isEqualTo: _passWord.value)
              .count()
              .get();

          if (resultCount.count! < 1) {
            throw ArgumentError();
          }

          if (!isUserIdExist) { // 사용자 ID가 존재하지 않을 때
            final SharedPreferences sharedPrefs = await SharedPreferences.getInstance(); // SharedPreferences : 안드로이드와 iOS에서 데이터를 영구 저장.
            sharedPrefs.setString('userId', Get.arguments["key"]); // Get.arguments["key"]는 어디서 전달 받은 인자 ??
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
      } else { // 기존 등록된 유저가 아닐 경우
        _isFirstPasswordDone.value = true; // 1차 비밀번호
        _recordPassWord.value = _passWord.value; // 1차 비밀번호 저장한 변수에 입력한 비밀번호를 저장
        _passWord.value = "";
      }
    }
  }

  // 사용자가 입력한 비밀번호를 확인하고, 일치하면 새로운 지갑을 생성하고 초기 설정을 진행합니다. 일치하지 않으면 스낵바를 통해 사용자에게 알림을 제공
  setConfirmPassWord(String value) async {
    if (value != "<" && _confirmPassWord.value.length < 6 && value != 'reset') { // if 조건 제외 시 입력 된다.
      _confirmPassWord.value = _confirmPassWord.value + value;
    }

    if (value == 'reset') { // 리셋 클릭
      _confirmPassWord.value = "";
    }

    if (value == "<") { // 백 스페이스
      if (_confirmPassWord.value.isEmpty) { // 문자열이 비어 있으면 리턴
        return;
      }
      _confirmPassWord.value = _confirmPassWord.value
          .substring(0, _confirmPassWord.value.length - 1);
    }

    if (_confirmPassWord.value.length == 6 &&
        _recordPassWord.value == _confirmPassWord.value && first) { //
      first = false;

      // find exist user
      // 등록된 유저인지 확인
      final tempDoc = await getx.db.collection(getUserCollectionName(getx.mode))
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid.toString())
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
          .get();

      late final userDoc;
      if (tempDoc.size == 0) {
        //create new userId : 새로운 유저 등록
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

      // 등록된 유저가 새로운 지갑을 생성 시 지갑 비밀번호만 업데이트
      await updateUserDB(getx.db, {
        "pw": _confirmPassWord.value,
      }, false);

      await getx.getInitialValue();

      Get.off(() => const PreIncubatorPage(), // 지갑 생성 완료 확인 페이지 이동.
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500));
    }

    if (_confirmPassWord.value.length == 6 &&
        _recordPassWord.value != _confirmPassWord.value &&
        !Get.isSnackbarOpen) { // 1차와 2차 비밀번호가 다를 경우
      Get.snackbar('password'.tr, 'password_check'.tr); // 'password': '비밀번호', 'password_check': '입력하신 비밀번호를 확인해주세요'
    }
  }

  // 로그아웃
  // 로그아웃 순서: GoogleProvider 로그아웃 -> Firebase 로그아웃 -> SharedPreferences 삭제 -> 지갑 파일 삭제
  logOut() async {
    // 각 단계 성공 여부
    bool googleSignOutSuccess = false;
    bool firebaseSignOutSuccess = false;
    bool sharedPreferencesRemoved = false;
    bool walletDeleted = false;

    try {
      // 1. GoogleProvider 로그아웃
      var clientId = Platform.isAndroid ? '441031740963-tf4oq8iknnu2u38lfbamdsblfs0d0eic.apps.googleusercontent.com' : '441031740963-huhdd8hiqf1c8lidj8cbc1hvgvrlllgo.apps.googleusercontent.com';
      GoogleProvider(clientId: clientId).logOutProvider(); // 로그아웃
      googleSignOutSuccess = true;

      // 2. Firebase 로그아웃
      FirebaseAuth.instance.signOut();
      firebaseSignOutSuccess = true;

      // 3. SharedPreferences 삭제
      /// SharedPreferences : Android에서 간단한 값을 저장
      ServiceAppInit().removeUserIdExist(); // 앱 저장된 userId와 uid 삭제
      sharedPreferencesRemoved = true;

      // 4. 지갑 파일 삭제
      Wallet.deleteKeystore; // 로그아웃 시 앱 내부에 생성된 지갑 파일도 삭제.
      walletDeleted = true;

      // 5. 로그인 여부 상태 변경
      getx.isUserIdExist = false; // 로그인한 유저 여부 false로 변경
    } catch (e) {
      String errorMsg = '';
      // 각 단계의 상태 복원
      if (googleSignOutSuccess) {
        // GoogleProvider 로그인 복구
        errorMsg = 'An issue occurred during logout.';
      }
      if (firebaseSignOutSuccess) {
        // Firebase 로그인 복구
        errorMsg = 'An issue occurred during logout.';
      }
      if (sharedPreferencesRemoved) {
        // SharedPreferences 삭제 롤백
        errorMsg = 'An issue occurred while deleting app records.';
      }
      if (walletDeleted) {
        // 지갑 파일 삭제 롤백
        errorMsg = 'An issue occurred while deleting the wallet file.';
      }

      await appendUserErrorDB(db, {
        "type": "logout_error",
        "error": e.toString(),
      });
      Get.snackbar('Logout Error', errorMsg);
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
