mixin StringUtil {
  String addSpace(String textToAddSpace, int spaceLength) {
    String result = '';
    for (int i = 0; i < spaceLength; i++) {
      result += ' ';
    }
    result += textToAddSpace;
    return result;
  }

  String addDash(int dashLength) {
    String result = '';
    for (int i = 0; i < dashLength; i++) {
      result += '-';
    }
    return result;
  }

  String textPrintFormat(String attritube, String align, String size) {
    return '';
    // return '$attritube]$align]$size]';
  }
}
