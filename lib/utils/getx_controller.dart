import 'dart:math';
import 'package:get/get.dart';
import 'package:ggnz/utils/const.dart';
import 'package:ggnz/utils/enums.dart';
import 'package:ggnz/utils/utility_function.dart';
import 'package:ggnz/web3dart/credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:ggnz/web3dart/web3dart.dart';
import 'package:ggnz/services/service_functions.dart';
import 'package:ggnz/presentation/pages/collecting/collecting_view_controller.dart';
import 'package:ggnz/presentation/pages/collecting/mission_view_controller.dart';
import 'package:ggnz/services/main_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 전역으로 가지고 있어야 할 데이터
class ReactiveCommonController extends GetxController {
  //baobab or main net
  // 사용 모드
  final mode = "userId";

  // web3dart 관련
  late final Web3Client client; // Web3.0 클라이언트. Ethereum 블록체인과의 상호작용을 담당
  late final chainID; // 현재 모드에 따른 체인 ID를 저장
  late double baitPrice; // BAIT 토큰의 가격을 나타내는 변수

  final RxString deviceID = "".obs; // 장치 ID를 관리

  // 서로 다른 스마트 계약에 대한 인스턴스
  /// DeployedContract : 이더리움 블록체인에 배포된 스마트 계약과 상호 작용하기 위한 헬퍼 클래스
  late DeployedContract dAppContract;
  late DeployedContract baitContract;
  late DeployedContract ggnzContract;
  late DeployedContract eggContract;
  late DeployedContract miscContract;
  late DeployedContract otpContract;

  int gogIndex = 1; // 보통알 인덱스
  int gopIndex = 2; // 특별한알 인덱스
  int ocnzIndex = 3; // 프리미엄알 인덱스

  late final bool isWalletExist;  // 생성된 지갑이 있는지 여부
  var isUserIdExist; // 로그인 상태인지 확인
  // late final bool isUserIdExist;

  // get data from firestore
  final firestore.FirebaseFirestore db = firestore.FirebaseFirestore.instance;

  // 사용자의 잔고 및 건강 등을 나타내는 변수
  RxDouble klay = 0.0.obs;
  RxDouble gog = 0.0.obs;
  RxDouble gop = 0.0.obs;
  RxDouble ocnz = 0.0.obs;
  RxDouble bait = 0.0.obs;
  RxDouble ggnz = 0.0.obs;
  RxDouble maxHealth = 0.0.obs;

  // 이미지 URL 및 정보를 관리하는 RxList 및 RxMap 변수
  final gogImageUrls = [].obs;
  final gopImageUrls = [].obs;
  final ocnzImageUrls = [].obs;
  final ocnzInfo = {}.obs;

  // 시간 관련 데이터를 관리
  final RxList woodBoxTime = [].obs; // 사용자가 나무 상자(woodbox)를 열 수 있는 시간을 관리
  final RxList continueTime = [].obs; // 사용자가 연속적으로 활동한 시간을 관리

  /// 지갑 주소
  RxString walletAddress = "".obs; // 사용자 지갑 주소
  RxString uid = "".obs; // 사용자 아이디
  RxMap keystoreFile = {}.obs; // keystore 파일을 관리

  /// 환경게이지
  RxDouble environmentLevel = 360.0.obs; // 현재 환경게이지 - 초기 : 360
  double environmentBad = 240.0; // 환경게이지 나쁨
  double environmentNormal = 480.0; // 환경게이지 보통
  double environmentGood = 600.0; // 환경게이지 좋음

  /// 건강도 (건강도는 전역으로 가지고 있다 새롭게 play 버튼을 누르면 사라지게 작업?)
  RxDouble healthLevel = 0.0.obs;

  // 아이템 사용, 보상 등을 관리
  final RxMap itemUsed = {}.obs;
  final RxMap getReward = {}.obs; // 보상
  final RxMap collectingReward = {}.obs;
  final collectingViewController = Get.find<CollectingViewController>();
  final missionViewController = Get.find<MissionViewController>();

  late final mainTimer timer; // 데이터베이스와 연동하여 타이머를 관리하는 인스턴스 */
  late final SharedPreferences sharedPrefs; // 앱의 간단한 데이터를 로컬 스토리지에 저장하기 위해 사용되는 객체 */

  // 초기화 함수로, Web3.0 클라이언트를 설정하고 체인 ID를 가져오는 작업 수행
  @override
  void onInit() {
    chainID = getChainID(mode);
    client = getClient(mode);
    timer = mainTimer(db);

    super.onInit();
  }

  // 초기 값 설정을 위한 함수. 계약 초기화, 사용자 잔고 가져오기, Firestore 데이터 가져오기 등의 작업을 수행. [시점] password_page_controller.dart의 setConfirmPassWord 메소드 실행 할때.
  Future<bool> getInitialValue() async {
    // 각 contract들을 해당 mode에 맞는 파일에서 가져와 초기화합니다.
    dAppContract = await getContract('assets/abis_test/OlchaeneezDAppControllerABI.json');
    baitContract = await getContract('assets/abis_test/OlchaeneezBaitABI.json');
    ggnzContract = await getContract('assets/abis_test/GGNZ.json');
    eggContract = await getContract('assets/abis_test/OlchaeneezEggABI.json');
    miscContract = await getContract('assets/abis_test/OlchaeneezMiscABI.json');
    otpContract = await getContract('assets/abis_test/OlchaeneezOfThePlanetABI.json');

    // SharedPreferences get 인스턴스
    try {
      sharedPrefs = await SharedPreferences.getInstance();
    } catch (e) {
    }

    try {
      if (walletAddress.value != "") {
        // if (mode == "abis") {
        await getGogGop(); // GOG(프리미엄 알), GOP(특별한 알)
        await checkErrorLength(db); // 사용자의 오류 로그 길이를 확인하고, 길이가 제한을 초과하는 경우 일부 로그를 삭제
        deviceID.value = await getDeviceInfo(); // 디바이스 정보를 가져와 Android의 경우 디바이스 ID를, iOS의 경우 identifierForVendor를 반환합니다.
        // }

        await getWalletCoinBalance(["BAIT"]);
        await getEggs(List.generate(3, (index) => BigInt.from(index + 1)));
        await getItems(List.generate(20, (index) => BigInt.from(index + 1)));

        await getCollectionData();
        await getDailyMissionData();

        baitPrice = 1;

        await getFirebaseInitialData();
        await checkCollecting();

        return true;
      }
    } catch (e) {
       await appendUserErrorDB(db, {
        "type": "starting application",
         "error": e.toString(),
      });
    }

    return false;
  }

  // 아이템 데이터를 가져오는 함수
  Future<bool> getItems(List<BigInt> itemIDs) async {
    final docData = (await db.collection(getUserCollectionName(mode)).doc(getx.walletAddress.value).get()).data();

    for (int idx = 0; idx < itemIDs.length; idx++) {
      final id = itemIDs[idx].toInt();
      late final item;
      if (id < 3) {
        // case of ItemBoxType
        item = ItemBoxType.getById(id);
      } else {
        // case of ItemNames
        item = ItemNames.getById(id);
      }

      items.value[item.key]?["amount"] = docData?['items']?[id.toString()]?.toInt() ?? 0;
    }
    return true;
  }

  // 알 관련 데이터를 가져오는 함수
  Future<bool> getEggs(List<BigInt> EggIDs) async {
    final docData = (await db.collection(getUserCollectionName(mode)).doc(getx.walletAddress.value).get()).data();

    for (int idx = 0; idx < EggIDs.length; idx++) {
      final egg_type = EggType.getById(EggIDs[idx].toInt());
      items.value[egg_type.key]?["amount"] = docData?['eggs']?[EggIDs[idx].toString()]?.toInt() ?? 0;
    }

    return true;
  }

  // GOG(프리미엄 알), GOP(특별한 알) 등의 데이터 가져오는 함수
  Future<bool> getGogGop() async {
    final docData = (await db.collection(getUserCollectionName(mode)).doc(getx.walletAddress.value).get()).data();

    getx.gog.value = docData?['gog']?.toDouble() ?? 0.0;
    getx.gop.value = docData?['gop']?.toDouble() ?? 0.0;
    getx.ocnz.value = docData?['ocnz']?.toDouble() ?? 0.0;

    print("test gog, gop, ocnz: ${getx.gog.value} ${getx.gop.value}");

    /*
    if (getx.gog.value > 0) {
      getGogImageURL();
    }

    if (getx.gop.value > 0) {
      getGopImageURL();
    }

    if (getx.ocnz.value > 0) {
      getOcnzImageURL();
    }
    */

    return true;
  }

  // KLAY, BAIT, GGNZ 지갑 잔고를 가져오는 함수
  Future<bool> getWalletCoinBalance(List<String> l) async {
    final docData = (await db.collection(getUserCollectionName(mode)).doc(getx.walletAddress.value).get()).data();

    if (l.contains("BAIT")) {
      getx.bait.value = docData?['bait']?.toDouble() ?? 0.0;
    }

    /*
    if (l.contains("BAIT")) {
      getx.bait.value = (await getx.client.call(
              sender: userAddress,
              contract: getx.baitContract,
              function: getx.baitContract.function("balanceOf"), // baitContract의 balanceOf 함수를 호출
              params: [userAddress, BigInt.one]))[0] // balanceOf 함수는 주어진 사용자 주소와 BigInt.one을 인자로 받아 잔액을 반환
          .toDouble();
    }

    if (l.contains("GGNZ")) {
      getx.ggnz.value = (await getx.client.call(
                  sender: userAddress,
                  contract: getx.ggnzContract,
                  function: getx.ggnzContract.function("balanceOf"), // ggnzContract의 balanceOf 함수를 호출
                  params: [userAddress]))[0] // balanceOf 함수는 주어진 사용자 주소를 인자로 받아 잔액을 반환
              .toDouble() /
          pow(10, 18); // 조회된 잔액을 toDouble()로 변환하고, 10^18로 나누어(=18자리 소수점) getx.ggnz.value에 저장
    }
    */

    return true;
  }

  // Firestore에서 초기 데이터를 가져오는 함수로, 환경 게이지, 나무상자 시간, 연속 접속 시간, 아이템 사용, 보상을 설정.  [시점] Future<bool> getInitialValue() 호출 시
  Future<void> getFirebaseInitialData() async {
    await db.collection(getUserCollectionName(mode))
        .doc(walletAddress.value)
        .get()
        .then((doc) async {
      if (doc.exists) {
        environmentLevel.value = doc.data()!["environmentLevel"] != null
            ? (doc.data()!["environmentLevel"].toDouble())
            : 360.0;

        if (doc.data()!["woodBoxTime"] != null) {
          woodBoxTime.value = doc.data()!["woodBoxTime"];
        }
        if (doc.data()!["continueTime"] != null) {
          continueTime.value = doc.data()!["continueTime"];
        }
        if (doc.data()!["itemUsed"] != null) {
          itemUsed.value = doc.data()!["itemUsed"];
        }
        if (doc.data()!["getReward"] != null) {
          getReward.value = doc.data()!["getReward"];
        }
      } else {
        await db
            .collection(getUserCollectionName(mode))
            .doc(getx.walletAddress.value)
            .set({
          "environmentLevel": 360.0,
          "woodBoxTime": [],
          "continueTime": [],
          "itemUsed": {},
          "getReward": {},
        });
      }

      timer.updateAll();
    });
  }

  // Firestore에서 수집 데이터를 가져와 collectingViewController.collectings에 리스트에 입력
  Future<void> getCollectionData() async {
    await db.collection("collection").orderBy("id").get().then((querySnapshot) {
      collectingViewController.collectings.value = [];

      for (var docSnapshot in querySnapshot.docs) {
        final data = docSnapshot.data();
        final require = collectingViewController.getRequire(data["mission"]);

        collectingViewController.collectings.value.add({ // 새로운 수집 항목을 추가합니다.
          "title": data["name"],
          "content": data["content"],
          "require": require,
          "current": 0,
          "mission": data["mission"],
          "reward": data["reward"],
          "rewards": collectingViewController.getRewardsList(data["reward"]),
        });
      }

      collectingViewController.collectings.value.add( // 특정 조건 만족하지 못해 추간된 빈 항목
          {'title': '', 'content': '', "require": 1, "current": 1, "rewards": []}
      );
    });
  }

  // 수집 관련 보상을 확인하고 관리하는 함수
  Future<void> checkCollecting() async {
    collectingReward.value = {
      "health": 0,
      "environment": 0,
    };

    for (var collecting in collectingViewController.collectings.value) {
      if (collecting["mission"] != null) {
        int current = collectingViewController.getCurrent(collecting["mission"]);
        collecting["current"] = current;

        if (collecting["require"] == current) {
          (collecting["reward"]! as Map).forEach((key, value) {
            collectingReward.value[key] += value;
          });
        }
      }
    }

    collectingViewController.getCollectings();
    collectingViewController.showSelectedOptions();
  }

  // Firestore에서 일일 미션 데이터를 가져오는 함수
  Future<void> getDailyMissionData() async {
    await db.collection("mission").orderBy("id").get().then((querySnapshot) {
      missionViewController.missions = [];

      for (var docSnapshot in querySnapshot.docs) {
        final data = docSnapshot.data();
        final int require = missionViewController.getRequire(data["mission"]);

        missionViewController.missions.add({
          "title": "",
          "id": data["id"],
          "content": data["content"],
          "complete_max_count": require,
          "complete_count": 0,
          "mission": data["mission"],
          "mission_type": missionViewController.getMissionType(data["type"]),
          "rewards": data["rewards_text"],
          "rewards_id": data["rewards_id"],
          "rewards_image": 'assets/iron_box.png',
          "isGetRewards": false
        });
      }
    });
  }

  // 특정 아이템 사용 횟수를 반환하는 함수
  int getItemUsedCount(String id) {
    if (itemUsed.value[id] != null) {
      return itemUsed.value[id]!;
    } else {
      return 0;
    }
  }

  // GOG 이미지 URL을 가져오는 함수
  void getGogImageURL() async {
    final gog = await client.call(
        sender: EthereumAddress.fromHex(getx.walletAddress.value),
        contract: getx.dAppContract,
        function: getx.dAppContract.function("tokenByIndexies"),
        params: [
          BigInt.from(gogIndex),
          BigInt.from(0),
          BigInt.from(getx.gog.value),
          EthereumAddress.fromHex(getx.walletAddress.value),
        ]);

    List<String> parsedGog = List.from(gog);
    gogImageUrls.value = [];

    if (parsedGog.isNotEmpty) {
      final gogTokenIDs = parsedGog[0]
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((gogTokenID) => int.parse(gogTokenID))
          .toList();
      final gogImages = gogTokenIDs
          .map((tokenID) =>
              'https://gaeguneez-v1.s3.ap-northeast-2.amazonaws.com/${tokenID}.png')
          .toList();

      if (gogImages.isNotEmpty) {
        getx.gogImageUrls.addAll(gogImages);
      }
    }
  }

  // GOP 이미지 URL을 가져오는 함수
  void getGopImageURL() async {
    final gop = await client.call(
        sender: EthereumAddress.fromHex(getx.walletAddress.value),
        contract: getx.dAppContract,
        function: getx.dAppContract.function("tokenByIndexies"),
        params: [
          BigInt.from(gopIndex),
          BigInt.from(0),
          BigInt.from(getx.gop.value),
          EthereumAddress.fromHex(getx.walletAddress.value),
        ]);

    List<String> parsedGop = List.from(gop);
    gopImageUrls.value = [];

    if (parsedGop.isNotEmpty) {
      final gopTokenIDs = parsedGop[0]
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((gopTokenID) => int.parse(gopTokenID))
          .toList();
      final gopImages = gopTokenIDs
          .map((tokenID) =>
              'https://gaeguneez-v2.s3.ap-northeast-2.amazonaws.com/${tokenID}.png')
          .toList();

      if (gopImages.isNotEmpty) {
        getx.gopImageUrls.addAll(gopImages);
      }
    }
  }

  // OCNZ 이미지 URL을 가져오는 함수
  void getOcnzImageURL() async {
    final ocnz = await client.call(
        sender: EthereumAddress.fromHex(getx.walletAddress.value),
        contract: getx.dAppContract,
        function: getx.dAppContract.function("tokenByIndexies"),
        params: [
          BigInt.from(ocnzIndex),
          BigInt.from(0),
          BigInt.from(getx.ocnz.value),
          EthereumAddress.fromHex(getx.walletAddress.value),
        ]);

    List<String> parsedOcnz = List.from(ocnz);
    ocnzImageUrls.value = [];

    if (parsedOcnz.isNotEmpty) {
      final ocnzTokenIDs = parsedOcnz[0]
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((ocnzTokenID) => int.parse(ocnzTokenID))
          .toList();

      await db.collection(getx.mode == "abis"? "nft": "nft_test")
          .where(TOKEN_ID, whereIn: ocnzTokenIDs)
          .where(HEALTH, isGreaterThanOrEqualTo: 0)
          .get().then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          final data = docSnapshot.data();
          ocnzInfo[data['image']] = data['health'];
          ocnzImageUrls.value.add(data['image']);
        }
      });
    }
  }

  // 알과 아이템의 각 세부 정보를 RxMao애 저장하고 초기화
  RxMap<String, Map<String, dynamic>> items = RxMap({
    ItemNames.pillS.key: {
      "imageUrl": ItemNames.pillS.imageUrl,
      "name": ItemNames.pillS.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 30.0,
      'inventoryItemDescription': '${ItemNames.pillS.key} Description',
      "tokenID": ItemNames.pillS.tokenID,
    },
    ItemNames.pillM.key: {
      "imageUrl": ItemNames.pillM.imageUrl,
      "name": ItemNames.pillM.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 60.0,
      'inventoryItemDescription': '${ItemNames.pillM.key} Description',
      "tokenID": ItemNames.pillM.tokenID,
    },
    ItemNames.pillL.key: {
      "imageUrl": ItemNames.pillL.imageUrl,
      "name": ItemNames.pillL.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 100.0,
      'inventoryItemDescription': '${ItemNames.pillL.key} Description',
      "tokenID": ItemNames.pillL.tokenID,
    },
    ItemNames.drinkS.key: {
      "imageUrl": ItemNames.drinkS.imageUrl,
      "name": ItemNames.drinkS.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 30.0,
      'inventoryItemDescription': '${ItemNames.drinkS.key} Description',
      "tokenID": ItemNames.drinkS.tokenID,
    },
    ItemNames.drinkM.key: {
      "imageUrl": ItemNames.drinkM.imageUrl,
      "name": ItemNames.drinkM.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 50.0,
      'inventoryItemDescription': '${ItemNames.drinkM.key} Description',
      "tokenID": ItemNames.drinkM.tokenID,
    },
    ItemNames.drinkL.key: {
      "imageUrl": ItemNames.drinkL.imageUrl,
      "name": ItemNames.drinkL.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 100.0,
      'inventoryItemDescription': '${ItemNames.drinkL.key} Description',
      "tokenID": ItemNames.drinkL.tokenID,
    },
    ItemNames.purifierAir.key: {
      "imageUrl": ItemNames.purifierAir.imageUrl,
      "name": ItemNames.purifierAir.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 10.0,
      'durability': 15.0,
      'inventoryItemDescription': '${ItemNames.purifierAir.key} Description',
      "tokenID": ItemNames.purifierAir.tokenID,
    },
    ItemNames.purifierVita.key: {
      "imageUrl": ItemNames.purifierVita.imageUrl,
      "name": ItemNames.purifierVita.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 20.0,
      'durability': 15.0,
      'inventoryItemDescription': '${ItemNames.purifierVita.key} Description',
      "tokenID": ItemNames.purifierVita.tokenID,
    },
    ItemNames.purifierBoyang.key: {
      "imageUrl": ItemNames.purifierBoyang.imageUrl,
      "name": ItemNames.purifierBoyang.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 30.0,
      'durability': 10.0,
      'inventoryItemDescription': '${ItemNames.purifierBoyang.key} Description',
      "tokenID": ItemNames.purifierBoyang.tokenID,
    },
    ItemNames.purifierCureAll.key: {
      "imageUrl": ItemNames.purifierCureAll.imageUrl,
      "name": ItemNames.purifierCureAll.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 80.0,
      'durability': 5.0,
      'inventoryItemDescription':
          '${ItemNames.purifierCureAll.key} Description',
      "tokenID": ItemNames.purifierCureAll.tokenID,
    },
    ItemNames.purifierImmortality.key: {
      "imageUrl": ItemNames.purifierImmortality.imageUrl,
      "name": ItemNames.purifierImmortality.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 120.0,
      'durability': 5.0,
      'inventoryItemDescription':
          '${ItemNames.purifierImmortality.key} Description',
      "tokenID": ItemNames.purifierImmortality.tokenID,
    },
    ItemNames.motor.key: {
      "imageUrl": ItemNames.motor.imageUrl,
      "name": ItemNames.motor.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 20.0,
      'durability': 15.0,
      'inventoryItemDescription': '${ItemNames.motor.key} Description',
      "tokenID": ItemNames.motor.tokenID,
    },
    ItemNames.motorRemodel.key: {
      "imageUrl": ItemNames.motorRemodel.imageUrl,
      "name": ItemNames.motorRemodel.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 40.0,
      'durability': 15.0,
      'inventoryItemDescription': '${ItemNames.motorRemodel.key} Description',
      "tokenID": ItemNames.motorRemodel.tokenID,
    },
    ItemNames.motorBlack.key: {
      "imageUrl": ItemNames.motorBlack.imageUrl,
      "name": ItemNames.motorBlack.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 60.0,
      'durability': 10.0,
      'inventoryItemDescription': '${ItemNames.motorBlack.key} Description',
      "tokenID": ItemNames.motorBlack.tokenID,
    },
    ItemNames.motorDash.key: {
      "imageUrl": ItemNames.motorDash.imageUrl,
      "name": ItemNames.motorDash.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 80.0,
      'durability': 5.0,
      'inventoryItemDescription': '${ItemNames.motorDash.key} Description',
      "tokenID": ItemNames.motorDash.tokenID,
    },
    ItemNames.motorGoldBlack.key: {
      "imageUrl": ItemNames.motorGoldBlack.imageUrl,
      "name": ItemNames.motorGoldBlack.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 100.0,
      'durability': 5.0,
      'inventoryItemDescription': '${ItemNames.motorGoldBlack.key} Description',
      "tokenID": ItemNames.motorGoldBlack.tokenID,
    },
    ItemNames.motorPlazmaDash.key: {
      "imageUrl": ItemNames.motorPlazmaDash.imageUrl,
      "name": ItemNames.motorPlazmaDash.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 120.0,
      'durability': 5.0,
      'inventoryItemDescription':
          '${ItemNames.motorPlazmaDash.key} Description',
      "tokenID": ItemNames.motorPlazmaDash.tokenID,
    },
    ItemNames.OCNZMint.key: {
      "imageUrl": ItemNames.OCNZMint.imageUrl,
      "name": ItemNames.OCNZMint.key,
      "amount": 0,
      'itemTo': '',
      'abilityType': ItemAbilityType.mint.name,
      "abilityCount": 0,
      'inventoryItemDescription': '${ItemNames.OCNZMint.key} Description',
      "tokenID": ItemNames.OCNZMint.tokenID,
    },
    "egg": {
      "imageUrl": EggType.egg.imageUrl,
      "name": EggType.egg.name,
      'abilityType': ItemAbilityType.egg.name,
      "eggID": EggType.egg.eggID,
      "amount": 0,
    },
    "eggSpecial": {
      "imageUrl": EggType.eggSpecial.imageUrl,
      "name": EggType.eggSpecial.name,
      'abilityType': ItemAbilityType.egg.name,
      "eggID": EggType.eggSpecial.eggID,
      "amount": 0,
    },
    "eggPremium": {
      "imageUrl": EggType.eggPremium.imageUrl,
      "name": EggType.eggPremium.name,
      'abilityType': ItemAbilityType.egg.name,
      "eggID": EggType.eggPremium.eggID,
      "amount": 0,
    },
    ItemBoxType.woodRandomBox.key: {
      "imageUrl": ItemBoxType.woodRandomBox.imageUrl,
      "name": ItemBoxType.woodRandomBox.key,
      'abilityType': ItemAbilityType.itembox.name,
      "amount": 0,
      'inventoryItemDescription':
          '${ItemBoxType.woodRandomBox.key} Description',
      "tokenID": ItemBoxType.woodRandomBox.tokenID,
    },
    // ItemBoxType.ironRandomBox.key: {
    //   "imageUrl": ItemBoxType.ironRandomBox.imageUrl,
    //   "name": ItemBoxType.ironRandomBox.key,
    //   'abilityType': ItemAbilityType.itembox.name,
    //   "amount": 0,
    //   'inventoryItemDescription':
    //       '${ItemBoxType.ironRandomBox.key} Description',
    // "tokenID": ItemBoxType.ironRandomBox.tokenID,
    // },
  });

  late Web3PrivateKey credentials;
  RxDouble volume = 100.0.obs;
  RxInt environmentTime = 0.obs;
  RxBool isBackground = false.obs; // 앱의 백그라운드 상태
}

final getx = Get.put(ReactiveCommonController());
