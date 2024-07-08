import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/collecting/models/nft_model.dart';

class EncyclopediaViewController extends GetxController {
  final _isGogOpen = true.obs;
  bool get isGogOpen => _isGogOpen.value;
  toggleGogOpen() {
    _isGogOpen.value = !_isGogOpen.value;
  }

  final _isGopOpen = true.obs;
  bool get isGopOpen => _isGopOpen.value;
  toggleGopOpen() {
    _isGopOpen.value = !_isGopOpen.value;
  }

  final _isOcnzOpen = true.obs;
  bool get isOcnzOpen => _isOcnzOpen.value;
  toggleOcnzOpen() {
    _isOcnzOpen.value = !_isOcnzOpen.value;
  }

  toggleNftOpen({required String nftTitle}) {
    if (nftTitle == 'GOG') {
      toggleGogOpen();
      return;
    }
    if (nftTitle == 'GOP') {
      toggleGopOpen();
      return;
    }
    if (nftTitle == 'OCNZ') {
      toggleOcnzOpen();
      return;
    }
  }

  // 도감 Read
  void getEnCyclopedia() {}

  final db = FirebaseFirestore.instance;

  RxList<NftTest> testData = RxList<NftTest>([]);
  getNftData() async {
    final test = await db.collection('nft_test').get().then(
        (value) => value.docs.map((doc) => NftTest.fromDocumentSnapshot(doc)));

    testData.addAll(test.toList());
  }

  @override
  void onInit() {
    getNftData();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
