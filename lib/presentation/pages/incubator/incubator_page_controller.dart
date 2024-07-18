import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:ggnz/presentation/pages/wallet/sign_wallet_page.dart';
import 'package:ggnz/presentation/widgets/dialog/mission_item_dialog.dart';
import 'package:ggnz/services/exchange_handler.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:ggnz/services/main_timer.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/enums.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntp/ntp.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ggnz/presentation/widgets/dialog/open_box_dialog.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:ggnz/presentation/widgets/dialog/item_dialog.dart';
import 'package:ggnz/presentation/widgets/dialog/loading_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ggnz/presentation/widgets/dialog/dispatch_dialog.dart';
import 'package:ggnz/presentation/pages/market/market_page.dart';

import 'package:ggnz/services/buying_handler.dart';
import 'package:ggnz/services/task_handler.dart';
import 'package:ggnz/services/dispatch_handler.dart';
import 'package:ggnz/services/minting_handler.dart';
import 'package:ggnz/services/notification_handler.dart';
import 'package:ggnz/presentation/widgets/dialog/play_continue_dialog.dart';
import 'package:ggnz/presentation/widgets/dialog/mission_item_dialog.dart';
import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:ggnz/utils/utility_function.dart';
import 'package:uuid/uuid.dart';

class IncubatorPageController extends GetxController
    with WidgetsBindingObserver {
  GGNZIncubateHandler? incubator = null;
  int? lastUsedTime = null;
  bool? lastIsLocked = null;

  // 배치 아이템 이미지명
  final _arrangementItemImage = ''.obs;
  String get arrangementItemImage => _arrangementItemImage.value;
  void setArrangementItemImage({required String image}) {
    _arrangementItemImage.value = image;
  }

  //보유 아이템 수량 체크(잠 깨우기 시 선택할 수 있는 아이템 수량 체크)
  final _isItemAmountZero = RxBool(getx.items.keys
      .where((key) =>
          getx.items[key]!['amount'] > 0 &&
          (getx.items[key]!['abilityType'] != ItemAbilityType.itembox.name ||
              getx.items[key]!['abilityType'] != ItemAbilityType.egg.name ||
              getx.items[key]!['abilityType'] != ItemAbilityType.mint.name))
      .toList()
      .isEmpty);
  bool get isItemAmountZero => _isItemAmountZero.value;

  //파견 보내기 버튼 활성화
  final _isDispatch = false.obs;
  bool get isDispatch => _isDispatch.value;
  void setIsDispatch() {
    _isDispatch.value = true;
    Future.delayed(Duration(seconds: 6), () => _isDispatch.value = false);
  }

  //firebase cloud firestore
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // 분양하기 버튼 상태 변화
  final _isPlaying = false.obs; /* 부화 상태 ?? */
  bool get isPlaying => _isPlaying.value;
  set setIsPlaying(bool b) => _isPlaying.value = b;

  // 파츠 성장 완료 상태
  final _isIncubatorDone = false.obs;
  bool get isIncubatorDone => _isIncubatorDone.value;
  set setIsIncubatorDone(bool b) => _isIncubatorDone.value = b;

  // 건강도
  final _healthLevel = getx.healthLevel;
  double get healthLevel => _healthLevel.value;

  // 성장 단계별 마리모 이미지 누적 변수
  final Rx<List<String>> _marimoList = Rx(List.generate(13, (index) => ''));
  List<String> get marimoList => _marimoList.value;

  // fireabse 데이터 전달 용도
  final Rx<Map<String, String>> _marimoPartsNumMap = Rx({});
  Map<String, String> get marimoPartsNumMap => _marimoPartsNumMap.value;
  StreamSubscription? checkMintingStream; /// StreamSubscription : 스트림으로부터 발생하는 이벤트를 처리하는 데 사용. 스트림을 구독하고 관리

  // 민팅 가능 여부 판단
  final _isAbleMint = false.obs;
  bool get isAbleMint => _isAbleMint.value;
  void setIsAbleMint(bool b) {
    _isAbleMint.value = b;
  }

  //파츠 트랜지션 순서
  final _partsTransitionNumber = 0.obs;
  int get partsTransitionNumber => _partsTransitionNumber.value;
  void setPartsTransitionNumber() {
    _partsTransitionNumber.value++;
  }

  // 파츠 성장 구간별 게이지 변수
  late final List<double> partsGageList;
  final RxDouble _maxPartsGage = 60.0.obs;
  double get maxPartsGage => _maxPartsGage.value;
  final RxDouble _partsGage = 0.0.obs;
  double get partsGage => _partsGage.value;

  //initialize foreground service
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isLoadingDialog = false;
  bool isContinueDialog = false;
  bool isAdsStarting = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (incubator != null) {
          final current_time = (await NTP.now()).millisecondsSinceEpoch;
          if (lastIsLocked! || (current_time - lastUsedTime!) < 10000) {

          } else if (!isContinueDialog) {
            isContinueDialog = true;
            final continue_result = await Get.dialog(PlayContinueDialog(),
                barrierDismissible: false,
                transitionCurve: Curves.decelerate,
                transitionDuration: Duration(milliseconds: 500));

            isContinueDialog = false;
            if (!continue_result) {
              getx.environmentLevel.value =
                  max(0, getx.environmentLevel.value - 20 - 3 * ((current_time - lastUsedTime!) ~/ 60000));
            }
          }
          incubator!.resumeIncubating((current_time - lastUsedTime!) ~/ 1000);
        }
        break;
      case AppLifecycleState.inactive:
        if (incubator != null && incubator!.isRunning) {
          incubator!.pauseIncubating();
          lastIsLocked = await isLockScreen();
          lastUsedTime = (await NTP.now()).millisecondsSinceEpoch;
          if (!isAdsStarting && !lastIsLocked!) {
            await _showNotification();
          }
        }
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<String> getErrorMessage(String message, String serviceType) async {
    appendUserErrorDB(db, {"type": serviceType, "error": message});

    if (message.contains('gas required exceeds allowance')) {
      if (serviceType == 'awake_egg') {
        return 'not_enough_gas_awake'.tr;
      }
      return 'not_enough_gas'.tr;
    }
    if (message.contains(
        'execution reverted: KIP37: insufficient balance for transfer')) {
      if (serviceType == 'awake_egg') {
        bool result = await Get.to(
            () => SignWalletPage(signReason: 'wants_to_buy_egg'.tr),
            arguments: {"reason": "wants_to_buy_egg"});

        if (result) {
          Get.to(() => const MarketPage(),
              arguments: {'market_type': 1},
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500));
        }
        return '';
      }
      return 'not_enough_items'.tr;
    }
    if (message.contains(
        'execution reverted: KIP7: transfer amount exceeds balance')) {
      return 'contact_administrator'.tr;
    }
    if (message.contains('evm: execution reverted')) {
      return 'not_enough_token'.tr;
    }
    if (message == "already dispatched from another device") {
      return 'dispatch_device_error'.tr;
    }

    return 'already_running_service'.tr;
  }

  // 알 사운드 관련 컨트롤러
  final eggStateAudioController = Get.find<EggStateAudioController>();
  final emotionAudioController = Get.find<EmotionAudioController>();

  // 성장 시간 - 보통알(10% 성체) , 특별알 (50% 성체), 프리미엄알(100% 성체)
  int checkPartsTimeLimit(int pageNum) { /* pageNum = 0 : 보통알, 1 : 특별알, 2 : 프리미엄알 */
    List<int> partsTimeList = pageNum == 0
        ? List.generate(
            10,
            ((index) => index == 9
                ? partsGageList[4].toInt()
                : partsGageList[3].toInt()))
        : pageNum == 1
            ? [partsGageList[4].toInt(), partsGageList[3].toInt()]
            : [partsGageList[4].toInt()];
    partsTimeList.shuffle();
    return partsTimeList[0];
  }

  //게이지 변경 함수 (함수 명 변경 필요)
  setMarimoGage(int pageNum, int partsTimeLimit, double gage) {
    if (gage < partsGageList[0]) {
      _maxPartsGage.value = partsGageList[0];
      _partsGage.value = gage;
    } else if (gage < partsGageList[1]) {
      _maxPartsGage.value = partsGageList[1] - partsGageList[0];
      _partsGage.value = gage - partsGageList[0];
    } else if (gage < partsGageList[2]) {
      _maxPartsGage.value = partsGageList[2] - partsGageList[1];
      _partsGage.value = gage - partsGageList[1];
    } else {
      _maxPartsGage.value = partsTimeLimit - partsGageList[2];
      _partsGage.value = gage - partsGageList[2];
    }

    if (gage == partsGageList[0]) {
      eggStateAudioController.pauseAudioPlayer();
      setPartsTransition(hasLeg: false);
    } else if (gage == partsGageList[1]) {
      setPartsTransition(hasLeg: true);
    } else if (gage == partsGageList[2]) {
      setPartsTransition(hasLeg: true);
    } else if (gage == partsGageList[3] && partsTimeLimit == partsGageList[4]) {
      setPartsTransition(hasLeg: true);
    }
  }

  // 파츠 성장 진화시 트랜지션 이미지 상태
  final _isPartsTransition = false.obs;
  bool get isPartsTransition => _isPartsTransition.value;

  //효과음 컨트롤러
  final _audioController = Get.find<AudioController>();

  // 파츠 성장 단계별 진화시 트랜지션
  void setPartsTransition({required bool hasLeg}) {
    setPartsTransitionNumber();
    _audioController.openAudioPlayer(url: 'assets/sound/parts_transition.mp3');
    _isPartsTransition.value = true;
    Future.delayed(const Duration(milliseconds: 4200), () {
      _isPartsTransition.value = false;
      imageCache.clear();
      if (hasLeg) {
        _audioController.openAudioPlayer(
            url: 'assets/sound/move_olchaeniz.mp3', isLoop: true);
      }
    });
  }

  double getHealthPlusePercent() {
    double plusPercent = 1.0 + (getx.collectingReward.value["health"] / 100);
    if (items[clickedItem] != null &&
        items[clickedItem]!['itemTo'] == ItemTo.health.name &&
        items[clickedItem]!['abilityType'] == ItemAbilityType.percent.name) {
      plusPercent += items[clickedItem]!['abilityCount'];
    }

    return plusPercent;
  }

  double getHealthInitial() {
    double healthInitial = 0.0;
    if (items[clickedItem] != null &&
        items[clickedItem]!['itemTo'] == ItemTo.health.name &&
        items[clickedItem]!['abilityType'] == ItemAbilityType.count.name) {
      healthInitial += items[clickedItem]!['abilityCount'];
    }

    return healthInitial;
  }

  final _environmentPlusCount = 1.0.obs;
  double get environmentPlusCount => _environmentPlusCount.value;
  set setEnvironmentPlusCount(double count) =>
      _environmentPlusCount.value = count;

  // 환경게이지 변수에 따른 배경이미지 트랜지션 상태
  final _isBackgroundTransition = false.obs;
  bool get isBackgroundTransition => _isBackgroundTransition.value;

  // 환경게이지 변수에 따른 배경이미지 트랜지션 상태 변경 함수
  void setBackgroundTransition() {
    _isBackgroundTransition.value = true;
    Future.delayed(const Duration(seconds: 3), () {
      _isBackgroundTransition.value = false;
    });
  }

  //환경게이지 함수
  double setEnvironmentLevelTimer() {
    _environmentPlusCount.value = 1.0 + (getx.collectingReward.value["environment"] / 100);
    double environment_initial = 0;

    if (items[clickedItem] != null &&
        items[clickedItem]!['itemTo'] == ItemTo.environment.name &&
        items[clickedItem]!['abilityType'] == ItemAbilityType.count.name) {
      environment_initial = items[clickedItem]!['abilityCount'];
    }

    if (items[clickedItem] != null &&
        items[clickedItem]!['itemTo'] == ItemTo.environment.name &&
        items[clickedItem]!['abilityType'] == ItemAbilityType.percent.name) {
      final double plusPercent = items[clickedItem]!['abilityCount'];
      _environmentPlusCount.value = 1.0 + (plusPercent / 100);
    }

    return environment_initial;
  }

  // 환경게이지에 스트림 배경 이미지 변경 변수 & 함수
  final Rx<String> _backgroundStateImage =
      getx.environmentLevel.value < getx.environmentBad /* 환경게이지 < 환경게이지 나쁨 */
          ? 'assets/bg0.gif'.obs
          : getx.environmentLevel.value < getx.environmentNormal
              ? 'assets/bg1.gif'.obs
              : 'assets/bg2.gif'.obs;
  String get backgroundStateImage => _backgroundStateImage.value;

  final Rx<String> _environmentState =
      getx.environmentLevel.value < getx.environmentBad
          ? EnvironmentState.bad.name.obs
          : getx.environmentLevel.value < getx.environmentNormal
              ? EnvironmentState.normal.name.obs
              : EnvironmentState.good.name.obs;

  String get environmentState => _environmentState.value;

  StreamSubscription? _environmentLevelSubscriptionsStream;

  void listenEnvironmentLevel() {
    _environmentLevelSubscriptionsStream =
        getx.environmentLevel.listen((value) {
      if (value == getx.environmentBad || value == getx.environmentNormal) {
        setBackgroundTransition();
      }

      if (value < getx.environmentBad) {
        _environmentState.value = EnvironmentState.bad.name;
        _backgroundStateImage.value = "assets/bg0.gif";
      } else if (value < getx.environmentNormal) {
        _environmentState.value = EnvironmentState.normal.name;
        _backgroundStateImage.value = "assets/bg1.gif";
      } else {
        _environmentState.value = EnvironmentState.good.name;
        _backgroundStateImage.value = "assets/bg2.gif";
      }
    });
  }

// 알 별 현재 출력 페이지 인디케이터 체크 변수
  final _indicatorCount = 0.obs;
  int get indicatorCount => _indicatorCount.value;
  set setIndicatorCount(int value) => _indicatorCount.value = value;

// 알 별 페이지 버튼 활성화 체크 변수
  final Rx<Map<int, bool>> _indicatorCountState =
      Rx({0: true, 1: getx.gog > 0, 2: getx.gop > 0});
  Map<int, bool> get indicatorCountState => _indicatorCountState.value;

  void setIndicatorCountState(int key, bool value) {
    _indicatorCountState.value[key] = value;
  }

  bool getIndicatorCountState(int num) {
    return _indicatorCountState.value[num] == null ||
            _indicatorCountState.value[num] == false
        ? false
        : true;
  }

  //아이템 관련 변수 & 함수
  final _items = getx.items;
  Map<String, Map<String, dynamic>> get items => _items;
  final _clickedItem = "".obs;
  String get clickedItem => _clickedItem.value;
  set setClickedItem(String itemName) => _clickedItem.value = itemName;

  // 알이 잠에서 깨어 있는지의 여부
  final _eggAwake = false.obs;
  bool get eggAwake => _eggAwake.value;
  set setEggAwake(bool b) => _eggAwake.value = b;

  // 페이지 뷰 이동 체크
  final _isPageViewClick = false.obs;
  bool get isPageViewClick => _isPageViewClick.value;
  void setIsPageViewClick() {
    _isPageViewClick.value = true;
    Future.delayed(
        Duration(milliseconds: 600), (() => _isPageViewClick.value = false));
  }

  void resumeMarimo(marimo_data) {
    if (marimo_data["itemID"] != null) {
      final itemName = ItemNames.getById(marimo_data["itemID"]).key;

      if (getx.items[itemName]!['abilityType'] != ItemAbilityType.count.name) {
        setClickedItem = itemName;
      }
    }

    _marimoList.value = marimo_data["marimoList"]?.cast<String>();
    _marimoPartsNumMap.value = marimo_data["marimoPartsNumMap"]?.cast<String, String>();
    getx.environmentTime.value = marimo_data["environmentTime"];
    setMarimoGage(marimo_data["eggID"] - 1, marimo_data["time_interval"], marimo_data["time"].toDouble());
    startTimer(eggsPageNum: marimo_data["eggID"] - 1, needToPay: false, data: {
      'id': marimo_data["id"],
      'time_interval': marimo_data["time_interval"],
      'health': marimo_data["health"],
      'time': marimo_data["time"],
      'marimoPartCheck': marimo_data["marimoPartCheck"],
    });
  }

  void checkStartingServer() async {
    setClickedItem = "";
    await db
        .collection(getUserCollectionName(getx.mode))
        .doc(getx.walletAddress.value)
        .get()
        .then((doc) async {
      final marimo_data = doc.data()!["marimo"];

      if (marimo_data != null) {
        checkMarimoData(marimo_data, checkPartsTimeLimit(marimo_data["eggID"] - 1));
        // check saved data
        final result = await Get.to(
            () => SignWalletPage(
                  signReason: 'check_egg'.tr,
                ),
            arguments: {"reason": "check_egg"});
        if (result) {
          // start with loaded data
          resumeMarimo(marimo_data);
        } else {
          // delete existing data
          Get.dialog(
            const ItemDialog(),
          );
        }
      } else {
        Get.dialog(
          const ItemDialog(),
        );
      }
    });
  }

  // 분양하기 버튼 함수
  void startTimer({required int eggsPageNum, required bool needToPay, required Map data}) async {
    openLoadingDialog(); /* 로딩 중.. 로딩 다이얼로그 표시 */
    await getx.getInitialValue(); /* 초기값 가져오기 */

    int partsTimeLimit = 0; /* 타이머 제한 변수 */
    final double environment_initial = setEnvironmentLevelTimer(); //함수 명 변경 필요
    late final String marimo_id;

    if (needToPay) { /* 결재 필요한 경우 */
      partsTimeLimit = checkPartsTimeLimit(eggsPageNum);
      marimo_id = Uuid().v4(); /* Uuid().v4() : 고유한 ID를 생성. */
    } else { /* 결재가 필요하지 않은 겨우 */
      partsTimeLimit = data["time_interval"];
      marimo_id = data["id"] != null? data["id"] : Uuid().v4();
    }

    incubator = new GGNZIncubateHandler({ /* incubator 초기화 */
      "db": db,
      "id": marimo_id,
      "time_interval": partsTimeLimit,
      "time": data["time"],
      "page_num": eggsPageNum,
      "used_item": clickedItem == "" ? -1 : items[clickedItem]!["tokenID"],
      "health_initial": data["health"] + getHealthInitial(),
      "health_plus_percent": getHealthPlusePercent(),
      "environment_initial": environment_initial,
      "environment_plus_count": _environmentPlusCount.value,
      "marimoPartCheck": data["marimoPartCheck"]
    });

    // incubator 실행 및 결과 처리
    if (incubator != null) {
      final awake_result = await incubator!.initIncubator(needToPay); /* 사용자가 결제 지불해야 하는지 여부에 따라 marimo의 incubator을 초기화 기능 수행 */
      print("test awake result: ${awake_result}");

      closeLoadingDialog(); /* 로딩 다이얼로그를 닫는다. */
      if (awake_result["result"] == "success") { /* 알에서 깨기 성공 할 경우 */
        _isPlaying.value = true;
        if (data["time"] < 5) { /* 시간이 5보다 적을 경우 ?? */
          _eggAwake.value = true; /* 알에서 깬 여부 변수에 알에서 깸을 저장 */
        }
        await getx.getEggs([BigInt.from(eggsPageNum + 1)]); /* 알 정보를 가져온다. */
        if (needToPay && awake_result["used_item"] != -1) { /* 결제 지불 했고 아이템을 사용했을 경우 */
          await getx.getItems([BigInt.from(awake_result["used_item"])]); /* 사용된 아이템 가져온다. */
          await db /* 사용자 데이터베이스 업데이트 */
              .collection(getUserCollectionName(getx.mode))
              .doc(getx.walletAddress.value)
              .update({
            "itemUsed.${awake_result["used_item"]}": FieldValue.increment(1), /* itemUsed 필드에서 사용된 아이템의 사용 횟수 +1  */
          });
        }
        incubator!.startIncubating(); /* 타이머를 사용하여 주기적으로 알 부화 상태를 체크하고, 특정 조건에 따라 건강 상태와 환경 수준을 업데이트하며, 데이터를 데이터베이스에 저장하는 작업을 수행 */
      } else {
        showSnackBar(await getErrorMessage(awake_result["error_message"], awake_result["type"])); /* 에러 내용을 스낵바로 표시 */
        finishIncubating(); /* incubating 종료 */
      }
    }
  }

  // 파견보내기 애니메이션이 모두 완료 되었는지 체크
  final _isDispatchAnimationDone = true.obs;
  bool get isDispatchAnimationDone => _isDispatchAnimationDone.value;
  void setIsDispatchAnimationDone({required bool dispatchAnimationDone}) {
    _isDispatchAnimationDone.value = dispatchAnimationDone;
  }

  // 파견보내기 버튼 함수
  void reset() async {
    _isDispatchAnimationDone.value = false;
    finishIncubating();
  }

  //민팅 함수
  // type 1: mint with ggnz, 2: mint with minting ticket
  void minting(type) async {
    openLoadingDialog();

    final String docID = getSHA256(marimoList.toString());
    bool mintingStart = true;

    // double check for minting
    await db
        .collection(getx.mode == "abis" ? "nft" : "nft_test")
        .doc(docID)
        .get()
        .then((doc) {
      if (doc.exists) {
        reset();
        showSnackBar('minting_failed'.tr);
        closeLoadingDialog();
        mintingStart = false;
      }
    });

    if (!mintingStart) {
      return;
    }

    final minting_result = await GGNZMintingHandler({
      'db': db,
      'docID': docID,
      "type": type,
    });

    print("test result: $minting_result");

    await getx.getGogGop();
    if (minting_result["result"] == "error") {
      showSnackBar(await getErrorMessage(
          minting_result["error_message"], minting_result["type"]));
    }
  }

  void dispatch(amount) async {
    openLoadingDialog();
    _audioController.openAudioPlayer(url: 'assets/sound/dispatch.mp3');

    Future.delayed(
        Duration(seconds: 1),
        () async {
          isLoadingDialog = false;
          final bool backtoPage = await Get.off(() => CreditTransitionPage(), transition: Transition.fadeIn);

          if (incubator != null && backtoPage) {
            openLoadingDialog();
          }
        }
    );

    final dispatch_result = await GGNZDispatchHandler({
      "db": db,
      "amount": amount,
      "id": incubator?.getID(),
      "mint_id": getSHA256(marimoList.toString()),
    });

    print("test dispatch result: ${dispatch_result}");

    if (dispatch_result["result"] == "success") {
      closeLoadingDialog();
      reset();
      showSnackBar('dispatch_complete'.tr);
      await getx.getWalletCoinBalance(["BAIT", "KLAY"]);
    } else {
      showSnackBar(await getErrorMessage(
          dispatch_result["error_message"], dispatch_result["type"]));
    }
  }

  void exchangeCoin(from, to, amount) async {
    openLoadingDialog();

    final reqResult = await GGNZExchangeCoin({
      "from": from,
      "to": to,
      "amount": amount,
      "db": db,
    });

    closeLoadingDialog();
    if (reqResult["result"] == "success") {
      showSnackBar('exchange_complete'.tr);
      await getx.getWalletCoinBalance(["BAIT", "GGNZ", "KLAY"]);
    } else {
      if (reqResult["result"] == "error" &&
          reqResult["error_message"] != null) {
        print("test error message: ${reqResult["error_message"]}");
        showSnackBar(await getErrorMessage(
            reqResult["error_message"]!, reqResult["type"]!));
      }
    }
  }

  void buyEgg(i) async {
    openLoadingDialog();

    loadAd((InterstitialAd ad) async {
      final reqResult = await GGNZBuyEgg({
        "db": db,
        "number": i,
      });

      closeLoadingDialog();
      if (reqResult["result"] == "success") {
        showSnackBar('egg_purchase_complete'.tr);
        await getx.getWalletCoinBalance(["KLAY"]);
      } else {
        if (reqResult["result"] == "error" &&
            reqResult["error_message"] != null) {
          print("test error message: ${reqResult["error_message"]}");
          showSnackBar(await getErrorMessage(
              reqResult["error_message"]!, reqResult["type"]!));
        }
      }

      ad.dispose();
    });
  }

  void buyItem(type, bool pay) async {
    openLoadingDialog();
    var reqResult;

    if (pay) {
      loadAd((ad) async {
        reqResult = await GGNZBuyItem({
          "type": type,
          "pay": pay,
          "db": db,
        });

        GGNZBuyItemResult(reqResult, type);
        ad.dispose();
      });
    } else {
      reqResult = await GGNZBuyItem({
        "type": type,
        "pay": pay,
        "db": db,
      });
      GGNZBuyItemResult(reqResult, type);
    }
  }

  void GGNZBuyItemResult(reqResult, type) async {
    closeLoadingDialog();
    if (reqResult["result"] == "success") {
      showSnackBar('random_box_purchase_completed'.tr);
      await getx.getItems([BigInt.from(1), BigInt.from(reqResult["tokenID"])]);
      await getx.getWalletCoinBalance(["KLAY"]);

      Get.dialog(
        OpenBoxDialog(
          imageUrl: type == 100
              ? 'assets/market/box_wooden_action.gif'
              : 'assets/market/box_iron_action.gif',
          boxType: type == 100 ? BoxType.wooden.name : BoxType.iron.name,
          itemName: reqResult["itemName"],
        ),
        transitionCurve: Curves.decelerate,
        transitionDuration: const Duration(seconds: 1),
      );
    } else {
      if (reqResult["result"] == "error" &&
          reqResult["error_message"] != null) {
        print("test error message: ${reqResult["error_message"]}");
        showSnackBar(await getErrorMessage(
            reqResult["error_message"]!, reqResult["type"]!));
      }
    }
  }

  void getMissionRewards(List<int> ids, String type) async {
    openLoadingDialog();

    final reqResult = await GGNZReward({
      "db": db,
      "rewards": ids,
      "type": type,
    });

    closeLoadingDialog();
    if (reqResult["result"] == "success") {
      for (var id in ids) {
        final item = ItemNames.getById(id);
        Get.dialog(
            MissionItemDialog(imageUrl: item.imageUrl, itemName: item.name));
      }
      await getx.getItems(reqResult["ids"]);
    } else {
      if (reqResult["result"] == "error" &&
          reqResult["error_message"] != null) {
        print("test error message: ${reqResult["error_message"]}");
        showSnackBar(await getErrorMessage(
            reqResult["error_message"]!, reqResult["type"]!));
      }
    }
  }

  void finishIncubating() async {
    await updateUserDB(db, {
      "marimo": FieldValue.delete(),
      "environmentLevel": getx.environmentLevel.value,
    }, false);

    if (checkMintingStream != null) {
      checkMintingStream!.cancel();
      checkMintingStream = null;
    }

    if (incubator != null) {
      incubator!.pauseIncubating();
      incubator = null;
    }

    _isPlaying.value = false;
    _isDispatch.value = false;
    _isAbleMint.value = false;
    _eggAwake.value = false;
    _isIncubatorDone.value = false;
    _isDispatchAnimationDone.value = true;
    _maxPartsGage.value = partsGageList[0];
    _partsGage.value = 0;
    getx.healthLevel.value = 0;
    getx.environmentTime.value = 0;
    _partsTransitionNumber.value = 0;
    _marimoList.value = List.generate(13, (index) => '');
    _marimoPartsNumMap.value = {};
    _clickedItem.value = "";
    imageCache.clear();
    getx.getInitialValue();
  }

  void showSnackBar(s) {
    if (s != '') {
      Get.snackbar('${Get.arguments}', '',
          padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
          backgroundColor: HexColor('#2E0C0C').withOpacity(0.7),
          duration: const Duration(seconds: 2),
          titleText: Center(
              child: Text(s,
                  style: TextStyle(
                    fontFamily: 'ONE_Mobile_POP_OTF',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ))));
    }
  }

  Future<void> checkMarimo(marimo_data) async {
    if (marimo_data != null) {
      checkMarimoData(marimo_data, checkPartsTimeLimit(marimo_data["eggID"] - 1));
      // check saved data
      final result = await Get.to(
              () => SignWalletPage(
            signReason: 'check_egg'.tr, /* 'check_egg': '이전에 키우던 올채니를 이어서 키우시겠습니까?' */
          ),
          arguments: {"reason": "check_egg"});
      if (result) {
        // start with loaded data
        resumeMarimo(marimo_data);
      } else { /*  */
        finishIncubating();
      }
    }
  }

  Future<void> checkDispatch(data) async {
    if (data != null) {
      final result = await Get.to(
          () => SignWalletPage(
                signReason: 'check_dispatch'.tr, /* 'check_dispatch': '방생 중이던 올채니를 이어서 방생하시겠습니까? */
              ),
          arguments: {
            "reason": 'dispatch_start',
            "amount": data["amount"],
          });
    }
  }

  Future<void> checkMinting(data) async {
    if (data != null) {
      final result = await Get.to(
          () => SignWalletPage(
                signReason: 'check_minting'.tr, /* 'check_minting': '입양 중이던 올채니를 이어서 입양 하시겠습니까?' */
              ),
          arguments: {"reason": 'MINT'},
          duration: Duration(milliseconds: 500),
          transition: Transition.fadeIn);

      if (result) {
        _marimoPartsNumMap.value = data["parts"];
        _marimoList.value = data["partsList"];
        minting(0);
      }
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('test_channel', 'test_channel_name',
            channelDescription: 'test for notification',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        1, '개구니즈', '올채니의 성장을 위해 앱으로 돌아가 주세요.', notificationDetails,
        payload: 'item x');
  }

  @override
  void onInit() async {
    final test_mode_ratio = 1;
    partsGageList = getx.mode == "abis"
        ? [60.0 * 60, 120.0 * 60, 180.0 * 60, 240.0 * 60, 300.0 * 60]
        : [60.0  * test_mode_ratio, 120.0  * test_mode_ratio, 180.0  * test_mode_ratio,
      240.0 * test_mode_ratio, 300.0 * test_mode_ratio];
    _maxPartsGage.value = partsGageList[0];
    MobileAds.instance.initialize();
    WidgetsBinding.instance.addObserver(this);

    await initialiseNotification(flutterLocalNotificationsPlugin);
    listenEnvironmentLevel();

    db.collection(getUserCollectionName(getx.mode))
        .doc(getx.walletAddress.value)
        .get()
        .then((doc) async {
          await checkMarimo(doc.data()?["marimo"]);
          //await checkDispatch(doc.data()?["dispatch"]);
          //await checkMinting(doc.data()?["minting"]);
    });

    super.onInit();
  }

  void openLoadingDialog() {
    Get.dialog(LoadingDialog(),
        barrierDismissible: false,
        transitionCurve: Curves.decelerate,
        transitionDuration: Duration(milliseconds: 500));
    isLoadingDialog = true;
  }

  void closeLoadingDialog() {
    if (isLoadingDialog) {
      Get.back();
      isLoadingDialog = false;
    }
  }

  void loadAd(Function(InterstitialAd) contentFunction) {
    final String iOSTestId = 'ca-app-pub-9634990372495017/2935532059';
    final String androidTestId = 'ca-app-pub-9634990372495017/5516365887';

    InterstitialAd.load(
        adUnitId: Platform.isIOS ? iOSTestId : androidTestId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) async {
              InterstitialAd loadedAd = ad;
              loadedAd.fullScreenContentCallback = FullScreenContentCallback(
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                onAdDismissedFullScreenContent: contentFunction,
              );
              loadedAd.show();
            },
            onAdFailedToLoad: (LoadAdError error ) {
              appendUserErrorDB(db, {
                "type": "ads_error",
                "error": error.toString()
              });

              print('onAdFailedToShowFullScreenContent: $error');
              closeLoadingDialog();
              showSnackBar('loading_ads'.tr);
            },
        )
    );
  }

  /*void createRewardedAd(Function(AdWithoutView, RewardItem) test) {
    RewardedAd? rewardedAd = null;
    isAdsStarting = true;
    final String iOSTestId = 'ca-app-pub-9634990372495017/9477647535';
    final String androidTestId = 'ca-app-pub-9634990372495017/2991114244';
    RewardedAd.load(
        adUnitId: Platform.isIOS ? iOSTestId : androidTestId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedAd = ad;

            rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (RewardedAd ad) {
                print('test onAdShowedFullScreenContent.');
              },
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                print('test onAdDismissedFullScreenContent.');
                isAdsStarting = false;
                lastIsLocked = true;
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
                appendUserErrorDB(db, {
                  "type": "ads_error",
                  "error": error.toString()
                });

                print('$ad onAdFailedToShowFullScreenContent: $error');
                closeLoadingDialog();
                showSnackBar('loading_ads'.tr);
                ad.dispose();
              },
              onAdImpression: (RewardedAd ad) =>
                  print('$ad impression occurred.'),
            );

            rewardedAd!.show(onUserEarnedReward: test);
          },
          onAdFailedToLoad: (LoadAdError error) {
            appendUserErrorDB(db, {
              "type": "ads_error",
              "error": error.toString()
            });

            closeLoadingDialog();
            showSnackBar('loading_ads'.tr);
          },
        ));
  }*/

  @override
  void onClose() {
    _environmentLevelSubscriptionsStream?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
