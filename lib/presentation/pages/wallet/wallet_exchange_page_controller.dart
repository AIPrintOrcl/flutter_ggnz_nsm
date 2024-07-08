import 'package:get/get.dart';

const List<String> coinNames = ['BAIT', 'GGNZ']; //, 'KLAY'

class WalletExchangeController extends GetxController {
  final _exchangeCoinsMap = {
    'BAIT': 'assets/coin/bait.png',
    'GGNZ': 'assets/coin/ggnz.png',
    //'KLAY': 'assets/coin/klay.png'
  };
  get exchangeCoinsMap => _exchangeCoinsMap;

  final RxInt baitAmount = 0.obs;
  final _selectedFromCoin = 'BAIT'.obs;
  String get selectedFromCoin => _selectedFromCoin.value;
  set setSelectedFromCoin(String coinName) {
    _selectedFromCoin.value = coinName;
    _selectedToCoin.value = coinNames[coinNames.indexOf(coinName) == 1
        ? coinNames.indexOf(coinName) - 1
        : coinNames.indexOf(coinName) + 1];
  }

  final RxInt ggnzAmount = 0.obs;
  final _selectedToCoin = 'GGNZ'.obs;
  String get selectedToCoin => _selectedToCoin.value;
  set setSelectedToCoin(String coinName) => _selectedToCoin.value = coinName;
}
