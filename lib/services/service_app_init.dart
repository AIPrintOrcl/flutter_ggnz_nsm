import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/app_stop_page.dart';
import 'package:ggnz/presentation/pages/main_page.dart';
import 'package:ggnz/presentation/pages/password/password_page.dart';
import 'package:ggnz/presentation/widgets/buttons/button_sound.dart';
import 'package:ggnz/utils/const.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:ggnz/web3dart/web3dart.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/pages/wallet/sign_wallet_page.dart';

// loading 중 필요한 데이터 체크
class ServiceAppInit extends GetxService {
  final buttonSoundController = Get.find<ButtonSoundController>();
  final db = firestore.FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final RxInt total_image = 1.obs;
  final RxInt current_image = 0.obs;

  // 로그인 여부(isUserIdExist) 및 등록된 지갑 여부(isWalletExist)에 따라 상황에 맞추어 페이지 이동
  void _checkWalletAddress() async {
    if (getx.isUserIdExist) {
      // v2 user
      Future.delayed(
          const Duration(seconds: 5),
              () => Get.off(() => const PasswordPage(),
              arguments: true,
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500)));
    } else if (getx.isWalletExist) {// 사용자 전환 안내 및 비밀번호 설정 페이지로 이동
      // 안내 메시지 1
      var result_1 = await Get.to(() => SignWalletPage(signReason: 'change_user_to_v2_1'.tr), // 'change_user_to_v2_1': '원활한 플레이 환경을 위해 서버를 변경하였습니다.',
          arguments: {"reason": "change_user_to_v2_1"});

      if (result_1) {
        // 안내 메시지 2
        var result_2 = await Get.to(() => SignWalletPage(signReason: 'change_user_to_v2_2'.tr), // 'change_user_to_v2_2': '이전 데이터는 저장되어 있으며 빠른 시일 내에 동기화 작업 진행 예정입니다.'
            arguments: {"reason": "change_user_to_v2_2"});
        if (result_2) { // 사용자 데이터 없는 경우 재생성
          Future.delayed(
              const Duration(seconds: 5),
                  () => Get.off(() => const PasswordPage(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500)));
        } else {
          exit(0);
        }
      } else {
        exit(0);
      }
    } else {
      // new user = 신규 유저
      Future.delayed(
          const Duration(seconds: 5),
              () => Get.off(() => const MainPage(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500)));
    }
  }

  // Firebase Firestore에서 앱의 설정 비교하고 앱의 버전 상태 확인
  void _checkFirebaseFireStore() {
    final docRef = db.collection(CONFIG);
    docRef.snapshots().listen(
          (event) async {
        bool appState = false;
        if (Platform.isAndroid) {
          appState = event.docs.first['androidState'];
        } else if (Platform.isIOS) {
          appState = event.docs.first['iosState'];
        }
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String buildNumber = packageInfo.buildNumber;

        // 앱의 빌드 번호와 비교하여 버전 업데이트 여부 확인
        if (int.parse(buildNumber) < event.docs.first["version"] || !appState && getx.mode == "abis") { // 버전이 낮거나 앱의 상태가 비활성 일 경우
          Future.delayed(Duration(seconds: 5), () {
            buttonSoundController.pauseSound();
            Get.to(() => const AppStopPage(),
                duration: Duration(milliseconds: 500),
                transition: Transition.fadeIn);
          });
        } else { // 그렇지 않을 경우 지갑 주소 유무 확인하고 사운드 재생한다.
          _checkWalletAddress();
          buttonSoundController.playSound();
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  // 앱의 빌드 번호 확인. 이전에 저장된 번호와 비교하여 변경 사항 존재할 경우 SharedPreferences(영구 저장소)에 저장한다.
  Future<void> checkBuildNumber() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform(); // 현재 빌드 번호 가져온다.
    String buildNumber = packageInfo.buildNumber;

    final lastNumber = sharedPrefs.getInt('lastNumber') ?? 0;
    if (lastNumber != int.parse(buildNumber)) { // 이전에 저장된 번호와 비교하여 변경 사항 존재할 경우 SharedPreferences(영구 저장소)에 저장한다.
      sharedPrefs.setBool('guide', false);
      sharedPrefs.setInt('lastNumber', int.parse(buildNumber));
    }
  }

  // 앱 내부에 저장된 userId와 uid 존재 여부 확인. 한번이라도 로그인 할 경우 앱 내부에 정보가 저장된다.
  Future<bool> checkUserIdExist() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    // userId 가 없는 경우 return false
    final userId = sharedPrefs.getString('userId') ?? '';
    final uid = sharedPrefs.getString('uid') ?? '';

    if (userId != '' || uid != '') {
      if (userId != '') {
        getx.walletAddress.value = userId;
      }
      if (uid != '') {
        getx.uid.value = uid;
      }
      return true;
    }

    return false;
  }

  // SharedPreferences(영구 저장소)에 저장된 데이터 삭제. 로그아웃 시 삭제되도록 하기 위함.
  Future<void> removeUserIdExist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('uid');
  }

  // 애플리케이션이 시작될 때 초기화해야 하는 작업 수행.
  void init() async {
    getx.isWalletExist = await Wallet.isKeystoreExist(); // 지갑 파일의 존재 여부 확인하고 업데이트한다.
    getx.isUserIdExist = await checkUserIdExist();

    await checkBuildNumber(); // 앱의 빌드 번호를 확인하고 SharedPreferences를 통해 관리하는 초기 설정을 업데이트
    await getx.getInitialValue(); // 초기 데이터 값 설정
  }

  // GetX의 라이프 사이클.
  @override
  void onInit() {
    init();
    _checkFirebaseFireStore();
    super.onInit();
  }
}
