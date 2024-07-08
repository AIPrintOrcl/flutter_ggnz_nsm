import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuidePageController extends GetxController {
  late SharedPreferences sharedPrefs;
  final RxBool _isSeenGuide = false.obs;
  get isSeenGuide => _isSeenGuide.value;
  void setIsSeenGuide() {
    _isSeenGuide.value = true;
    sharedPrefs.setBool('guide', true);
  }

  void init() async {
    sharedPrefs = await SharedPreferences.getInstance();
    chdckIsGuideOnFromSharedPrefs();
  }

  void chdckIsGuideOnFromSharedPrefs() async {
    _isSeenGuide.value = sharedPrefs.getBool('guide') ?? false;
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }
}
