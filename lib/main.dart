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
  await getPermission();
  await getStoragePermission();
  await getAndroidNotificationPermission();
  await getIOSNotificationPermission();
  SharedPreferences _sharedPrefs = await SharedPreferences.getInstance();

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
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // debugInvertOversizedImages = true;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GGNZ',
      translations: Languages(),
      locale: Get.deviceLocale,
      navigatorKey: Get.key,
      fallbackLocale: const Locale('ko', 'KR'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPageLoading(),
      initialBinding: BindingsBuilder((() {
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
        Get.put(WalletPageController());
        Get.put(ServiceAppInit()); // loading 중 필요한 데이터 체크
        Get.put(CheckAppStateController());
      })),
    );
  }
}
