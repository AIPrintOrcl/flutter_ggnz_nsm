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

// loading 중 필요한 데이터 체크
class ServiceAppInit extends GetxService {
  final buttonSoundController = Get.find<ButtonSoundController>();
  final db = firestore.FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final RxInt total_image = 1.obs;
  final RxInt current_image = 0.obs;

  void _checkWalletAddress() async {
    /*final infoRef = storage.ref().child("info");
    ListResult test = await infoRef.listAll();
    total_image.value = test.items.length;

    test.items.forEach((element) async {
      final appDocDir = await getApplicationDocumentsDirectory();
      final filePath = "${appDocDir.absolute}/images/info/${element.name}";
      final file = File(filePath);

      if (await file.exists()) {
        print("storage test: file ${element.name} already exist");
      } else {
        print("storage test: create file ${element.name}");
        print("storage test: ${infoRef.fullPath}");
        print("storage test: ${infoRef.child(element.name).fullPath}");
        final downloadTask = infoRef.child(element.name).writeToFile(file);
        await downloadTask.snapshotEvents.listen((taskSnapshot) {
          switch (taskSnapshot.state) {
            case TaskState.running:
            // TODO: Handle this case.
              break;
            case TaskState.paused:
            // TODO: Handle this case.
              break;
            case TaskState.success:
              current_image.value += 1;
              print("storage test: file download finished ${element.name}");
              break;
            case TaskState.canceled:
            // TODO: Handle this case.
              break;
            case TaskState.error:
              print("storage test: error ${taskSnapshot.toString()}");
            // TODO: Handle this case.
              break;
          }
        });
      }
    });

    print("storage test download completed!");*/
    if (getx.isWalletExist) {
      Future.delayed(
          const Duration(seconds: 5),
          () => Get.off(() => const PasswordPage(),
              arguments: true,
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500)));
    } else {
      Future.delayed(
          const Duration(seconds: 5),
          () => Get.off(() => const MainPage(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500)));
    }
  }

  Future<bool> getWalletAddress() async {
    if (getx.isWalletExist) {
      final walletFile = await Wallet.getJsonFromFile();
      getx.keystoreFile.value = json.decode(walletFile);
      getx.walletAddress.value = getx.keystoreFile["address"];

      return true;
    }

    return false;
  }

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

        if (int.parse(buildNumber) < event.docs.first["version"] || !appState && getx.mode == "abis") {
          Future.delayed(Duration(seconds: 5), () {
            buttonSoundController.pauseSound();
            Get.to(() => const AppStopPage(),
                duration: Duration(milliseconds: 500),
                transition: Transition.fadeIn);
          });
        } else {
          _checkWalletAddress();
          buttonSoundController.playSound();
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  Future<void> checkBuildNumber() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;

    final lastNumber = sharedPrefs.getInt('lastNumber') ?? 0;
    if (lastNumber != int.parse(buildNumber)) {
      sharedPrefs.setBool('guide', false);
      sharedPrefs.setInt('lastNumber', int.parse(buildNumber));
    }
  }

  void init() async {
    getx.isWalletExist = await Wallet.isKeystoreExist();

    await checkBuildNumber();
    await getWalletAddress();
    await getx.getInitialValue();
  }

  @override
  void onInit() {
    _checkFirebaseFireStore();
    init();
    super.onInit();
  }
}
