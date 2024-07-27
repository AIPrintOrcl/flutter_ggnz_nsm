// 이더리움의 다양한 단위를 정의
enum EtherUnit {
  ///Wei, the smallest and atomic amount of Ether = 가장 작은 단위, 1 ether = 10^18 wei
  wei,

  ///kwei, 1000 wei = 1,000 wei
  kwei,

  ///Mwei, one million wei = 1,000,000 wei
  mwei,

  ///Gwei, one billion wei. Typically a reasonable unit to measure gas prices. = 1,000,000,000 wei, 가스 가격 측정에 주로 사용됨
  gwei,

  ///szabo, 10^12 wei or 1 μEther = 1,000,000,000,000 wei
  szabo,

  ///finney, 10^15 wei or 1 mEther = 1,000,000,000,000,000 wei
  finney,

  /// 기본 단위, 1 ether = 10^18 wei
  ether
}

/// Utility class to easily convert amounts of Ether into different units of
/// quantities.
// 이더리움의 양을 다양한 단위로 변환하는 유틸리티 클래스
class EtherAmount {
  const EtherAmount.inWei(this._value); /* 주어진 wei 값을 사용하여 객체를 생성 */

  EtherAmount.zero() : this.inWei(BigInt.zero); /* 값이 0인 객체를 생성 */

  /// Constructs an amount of Ether by a unit and its amount. [amount] can
  /// either be a base10 string, an int, or a BigInt.
  // 주어진 단위와 값으로 객체를 생성합니다. amount는 BigInt, int, String 타입 중 하나일 수 있습니다.
  factory EtherAmount.fromUnitAndValue(EtherUnit unit, dynamic amount) {
    BigInt parsedAmount;

    if (amount is BigInt) {
      parsedAmount = amount;
    } else if (amount is int) {
      parsedAmount = BigInt.from(amount);
    } else if (amount is String) {
      parsedAmount = BigInt.parse(amount);
    } else {
      throw ArgumentError('Invalid type, must be BigInt, string or int');
    }

    return EtherAmount.inWei(parsedAmount * _factors[unit]!);
  }

  /// Gets the value of this amount in the specified unit as a whole number.
  /// **WARNING**: For all units except for [EtherUnit.wei], this method will
  /// discard the remainder occurring in the division, making it unsuitable for
  /// calculations or storage. You should store and process amounts of ether by
  /// using a BigInt storing the amount in wei.
  BigInt getValueInUnitBI(EtherUnit unit) => _value ~/ _factors[unit]!;

  static final Map<EtherUnit, BigInt> _factors = {
    EtherUnit.wei: BigInt.one,
    EtherUnit.kwei: BigInt.from(10).pow(3),
    EtherUnit.mwei: BigInt.from(10).pow(6),
    EtherUnit.gwei: BigInt.from(10).pow(9),
    EtherUnit.szabo: BigInt.from(10).pow(12),
    EtherUnit.finney: BigInt.from(10).pow(15),
    EtherUnit.ether: BigInt.from(10).pow(18)
  };

  final BigInt _value;

  BigInt get getInWei => _value;
  BigInt get getInEther => getValueInUnitBI(EtherUnit.ether);

  /// Gets the value of this amount in the specified unit. **WARNING**: Due to
  /// rounding errors, the return value of this function is not reliable,
  /// especially for larger amounts or smaller units. While it can be used to
  /// display the amount of ether in a human-readable format, it should not be
  /// used for anything else.
  double getValueInUnit(EtherUnit unit) {
    final factor = _factors[unit]!;
    final value = _value ~/ factor;
    final remainder = _value.remainder(factor);

    return value.toInt() + (remainder.toInt() / factor.toInt());
  }

  @override
  String toString() {
    return 'EtherAmount: $getInWei wei';
  }

  @override
  int get hashCode => getInWei.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is EtherAmount && other.getInWei == getInWei;
}
