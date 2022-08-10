mixin TypeUtil {
  int dynamicToInt(dynamic dyn) {
    return cast<int>(dyn) ?? 0;
  }

  double dynamicToDouble(dynamic dyn) {
    if (dyn is int) {
      final double result = dyn.toDouble();
      return ((result * 100).round().toDouble()) / 100;
    } else if (dyn is double) {
      return dyn;
    }
    return 0;
  }

  bool dynamicToBool(dynamic dyn) {
    return cast<bool>(dyn) ?? false;
  }

  List<List<String>> mapListToString2D(List<Map<String, dynamic>> maps) {
    return maps.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }
}

extension MapX on Map<String, dynamic> {
  dynamic get(int i) {
    return values.elementAt(i);
  }
}

T? cast<T>(x) => x is T ? x : null;
