import 'dart:collection';

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
    if (dyn is bool) {
      return dyn;
    } else if (dyn is int) {
      return dyn == 0 ? false : true;
    }
    return false;
  }

  List<List<String>> mapListToString2D(List<Map<String, dynamic>> maps) {
    return maps.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  List<String> mapToStringList(Map<String, dynamic> map) {
    return map.values.map((dynamic v) => v.toString()).toList();
  }

  List<List<double>> mapListToDouble2D(List<Map<String, dynamic>> maps) {
    return maps.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => dynamicToDouble(v)).toList();
    }).toList();
  }

  List<List<int>> mapListToInt2D(List<Map<String, dynamic>> maps) {
    return maps.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => dynamicToInt(v)).toList();
    }).toList();
  }

  List<List<dynamic>> mapListToDynamic2D(List<Map<String, dynamic>> maps) {
    return maps.map((Map<String, dynamic> e) {
      return e.values.toList();
    }).toList();
  }
}

extension MapX on Map<String, dynamic> {
  dynamic get(int i) {
    return this.values.elementAt(i);
  }
}

extension MapBaseX on MapBase<String, dynamic> {
  dynamic get(int i) {
    return this.values.elementAt(i);
  }
}

T? cast<T>(x) => x is T ? x : null;
