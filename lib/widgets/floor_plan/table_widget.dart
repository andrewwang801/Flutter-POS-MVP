import 'package:flutter/material.dart';

import 'package:raptorpos/model/table_model.dart';

import '../../constants/text_style_constant.dart';

class TableWidget extends StatefulWidget {
  final TableModel table;
  TableWidget({required this.table, Key? key}) : super(key: key);

  @override
  State<TableWidget> createState() => _TableWidgetState();
}

List<MaterialColor> tableColors = [
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
  Colors.grey,
  Colors.teal,
];

class _TableWidgetState extends State<TableWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.table.y,
      left: widget.table.x,
      width: widget.table.width,
      height: widget.table.height,
      child: Container(
        decoration:
            BoxDecoration(color: tableColors[widget.table.status], boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 2.0,
            spreadRadius: 2.0,
          ),
        ]),
        child: Center(
          child: Text(widget.table.label ?? '',
              textAlign: TextAlign.center, style: bodyTextLightStyle),
        ),
      ),
    );
  }
}
