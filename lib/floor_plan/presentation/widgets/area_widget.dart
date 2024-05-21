import 'package:flutter/material.dart';

import 'package:raptorpos/floor_plan/model/area_model.dart';

import '../../../constants/text_style_constant.dart';

class AreaWidget extends StatefulWidget {
  final AreaModel area;
  AreaWidget({required this.area, Key? key}) : super(key: key);

  @override
  State<AreaWidget> createState() => _AreaWidgetState();
}

List<MaterialColor> areaColors = [
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
  Colors.grey,
  Colors.teal,
];

class _AreaWidgetState extends State<AreaWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.area.y,
      left: widget.area.x,
      width: widget.area.width,
      height: widget.area.height,
      child: Container(
        decoration:
            BoxDecoration(color: areaColors[widget.area.status], boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 2.0,
            spreadRadius: 2.0,
          ),
        ]),
        child: Center(
          child: Text(
            widget.area.label ?? '',
            textAlign: TextAlign.center,
            style: bodyTextLightStyle,
          ),
        ),
      ),
    );
  }
}
