import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuidePageController extends GetxController {
  late SharedPreferences sharedPrefs;

  // 올체니즈 성장 가이드 표시 여부
  final RxBool _isSeenGuide = false.obs; /* isSeenGuide : 지갑 생성 시 최초만 가이드 표시 */
  get isSeenGuide => _isSeenGuide.value;

  // 가이드가 한 번 표시되었음을 기록
  void setIsSeenGuide() {
    _isSeenGuide.value = true;
    sharedPrefs.setBool('guide', true);
  }

  void init() async {
    sharedPrefs = await SharedPreferences.getInstance(); /* SharedPreferences : 간단한 데이터를 비동기적으로 디스크에 저장하는 기능을 제공. 디스크에서 로드하고 파싱하는 역할 */
    chdckIsGuideOnFromSharedPrefs();
  }

  void chdckIsGuideOnFromSharedPrefs() async {
    _isSeenGuide.value = sharedPrefs.getBool('guide') ?? false; /* getBool('guide')에 저장된 값이 있을 경우 그 값을 _isSeenGuide에 저장. 저장된 값이 없을 경우 false를 기본값으로 사용 */
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }
}
