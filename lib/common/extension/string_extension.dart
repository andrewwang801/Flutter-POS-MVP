extension StringExtension on String {
  int toInt() {
    return int.tryParse(this) ?? 0;
  }

  double toDouble() {
    double result = double.tryParse(this) ?? 0.0;
    return ((result * 100).round().toDouble()) / 100;
  }

  bool toBool() {
    final int temp = int.tryParse(this) ?? 0;
    if (temp == 1) {
      return true;
    }
    return false;
  }

  String currencyString(String currency) {
    return '$currency $this';
  }
}

extension BoolExtension on bool {
  int toInt() {
    if (this == true) {
      return 1;
    }
    return 0;
  }
}

extension IntExtension on int {
  bool toBool() {
    if (this == 0) {
      return false;
    }
    return true;
  }
}

extension DoubleExtension on double {
  String currencyString(String currency) {
    return '$currency $this';
  }
}
