extension StringExtension on String {
  int toInt() {
    return int.tryParse(this) ?? 0;
  }

  double toDouble() {
    return double.tryParse(this) ?? 0.0;
  }

  bool toBool() {
    int temp = int.tryParse(this) ?? 0;
    return temp == 1 ? true : false;
  }

  String currencyString(String currency) {
    return '$currency $this';
  }
}

extension BoolExtension on bool {
  int toInt() {
    return this == true ? 1 : 0;
  }
}

extension IntExtension on int {
  bool toBool() {
    return this == 0 ? false : true;
  }
}

extension DoubleExtension on double {}

T? cast<T>(x) => x is T ? x : null;
