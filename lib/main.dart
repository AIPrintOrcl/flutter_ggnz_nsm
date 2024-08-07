import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ggnz/firebase_options.dart';
import 'package:ggnz/presentation/pages/main_page_loading.dart';
import 'package:ggnz/presentation/pages/market/market_page_controller.dart';
import 'package:ggnz/presentation/pages/wallet/wallet_page_controller.dart';
import 'package:ggnz/presentation/widgets/buttons/button_sound.dart';
import 'package:ggnz/presentation/widgets/watch.dart';
import 'package:ggnz/services/service_app_init.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/check_app_state.dart';
import 'package:ggnz/utils/languages.dart';
import 'package:ggnz/utils/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/pages/collecting/collecting_page_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await getPermission(); // 시스템 경고창 생성 권한
  await getStoragePermission(); // 저장 권한 요청
  await getAndroidNotificationPermission(); // Android에서 알림 권한을 요청
  await getIOSNotificationPermission(); // IOS에서 알림 권한을 요청
  SharedPreferences _sharedPrefs = await SharedPreferences.getInstance(); // 로컬 데이터를 영구 저장 방법

  //make test wallet
  /*final wallet = await Wallet.fromJson("""{
    "version": 3,
    "id": "173951e6-e44a-49d1-acd1-58875a6fa93c",
    "address": "6fd885389df1f0eaee00f11c2f7163a6e1007af5",
    "crypto": {
      "ciphertext": "60f989458f9ca38f16e726228e4a601c3ca109793ffd920f6e3642cbe8629f33",
      "cipherparams": { "iv": "ee2db55a07a4be08a43689e3ddec7149" },
      "cipher": "aes-128-ctr",
      "kdf": "scrypt",
      "kdfparams": {
        "dklen": 32,
        "salt": "accecf844e8ff6ccd6b259d035468a7da7abbae562bacb555a834dd8fa60a669",
        "n": 8192,
        "r": 8,
        "p": 1
      },
      "mac": "f03b9951037db338f346275efec6461abb9292dc47bd71e1a068633fac51b8f8"
    }
  }""", "111111");

  await wallet.saveAsJsonFile(data: wallet.toJson());*/

  //await sp.init();

  // 앱의 화면 방향을 설정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // 앱의 화면 방향을 세로 방향으로 고정
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // debugInvertOversizedImages = true;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 모드에서 상단 배너 표시 여부
      title: 'GGNZ',
      translations: Languages(), // 다국어 지원을 위한 번역 파일 관리
      locale: Get.deviceLocale, // 애플리케이션의 현재 언어를 기기의 언어로 설정.
      navigatorKey: Get.key, // GetX 내비게이션의 키 설정
      fallbackLocale: const Locale('ko', 'KR'), // 기본 언어와 국가 설정.
      theme: ThemeData( // 애플리케이션의 테마 설정
        primarySwatch: Colors.blue,
      ),
      home: const MainPageLoading(), // 초기 화면
      initialBinding: BindingsBuilder((() { // initialBinding : 애플리케이션 시작 시 필요한 초기화 작업을 수행하는 바인딩(확정) 설정
        // BindingsBuilder : 다양한 컨트롤러들을 GetX의 의존성 관리 시스템에 등록.
        Get.put(CollectingPageController());
        Get.put(EggStateAudioController());
        Get.put(TransitionAudioController());
        Get.put(EmotionAudioController());
        Get.put(AudioController());
        Get.put(BgmController());
        Get.put(EnvironmentChangeAudioController());
        Get.put(ButtonSoundController());
        Get.put(MarketPageController());
        Get.put(WatchController());
        Get.put(WalletPageController()); // 지갑 패이지
        Get.put(ServiceAppInit()); // loading 중 필요한 데이터 체크
        Get.put(CheckAppStateController()); // 앱이 활성화/비활성화 될 때 특정 동작 수행. WidgetBindingObserver를 통해 앱 라이프사이클의 상태 변화 감지/미감지 및 getx.isBackground를 true/false로 변경
      })),
    );
  }
}
