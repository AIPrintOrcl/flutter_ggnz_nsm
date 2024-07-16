import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/incubator/incubator_page.dart';
import 'package:ggnz/presentation/pages/incubator/pre_incubator_page.dart';
import 'package:ggnz/web3dart/credentials.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/web3dart/crypto.dart';
import 'dart:math';

class PasswordPageController extends GetxController {
  // 비밀번호 주의사항 체크
  final _isClicked = false.obs;
  bool get isClicked => _isClicked.value;
  set setIsClicked(bool value) => _isClicked.value = value;


  final _walletAddress = "".obs;
  String get walletAddress => _walletAddress.value;
  set setWalletAddress(String value) => _walletAddress.value = value;

  final _isFirstPasswordDone = false.obs;
  bool get isFirstPasswordDone => _isFirstPasswordDone.value;

  late final bool isWalletExist;

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
      if (isWalletExist) {
        try {
          final walletFile = await Wallet.getJsonFromFile();
          getx.credentials = Wallet.fromJson(walletFile, '${_passWord.value}').privateKey;

          //privatekey
          //print("test private key: " + bytesToHex(getx.credentials.privateKey));

          Get.off(() => const IncubatorPage(), /* 게임 메인 페이지로 이동 */
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500)
          );
          return;
        } on ArgumentError {
          if (!Get.isSnackbarOpen) {
            Get.snackbar('지갑주소 비밀번호와 일치하지 않습니다.', '', duration: Duration(seconds: 1));
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
        _recordPassWord.value == _confirmPassWord.value) { /* 비밀번호 설정 완료 => 비밀번호가 6자리 이고 확인까지 끝난 비밀번호 */

      late final credential;

      // Get.arguments에서 "key" 값을 가져와서 조건에 따라 credential 초기화
      if (Get.arguments != null && Get.arguments["key"] != null) {
        credential = Web3PrivateKey.fromHex(Get.arguments["key"]); /* // 16진수 개인 생성 */
      } else {
        credential = Web3PrivateKey.createRandom(Random.secure()); /* 임의의 랜덤값으로 초기화 */
      }

      //create new wallet
      /// 지갑 생성
      Wallet wallet = Wallet.createNew(
          credential,
          _confirmPassWord.value, /* 키패드로 생성된 비밀번호 */
          Random.secure()
      );

      setWalletAddress = wallet.privateKey.address.hexEip55; /* 지갑 주소를 EIP-55 표준 형식으로 변경 후 변수에 저장 */
      getx.walletAddress.value = wallet.privateKey.address.hexEip55; /* 지갑 주소를 getx 상태 관리 객체 변수에 저장 */
      getx.credentials = wallet.privateKey; /* 지갑 개인키를 getx 상태 관리 객체 변수에 저장 => 자격증명 설정 */
      wallet.saveAsJsonFile(data: wallet.toJson()); /* 생성된 지갑 정보를 앱 자체 JSON 파일로 저장 */

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
    isWalletExist = getx.isWalletExist;
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
