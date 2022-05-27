import 'package:flutter/material.dart';

import 'package:raptorpos/floor_plan/model/area_model.dart';
import 'package:raptorpos/floor_plan/model/table_model.dart';
import 'area_widget.dart';
import 'table_widget.dart';

class FloorLayout extends StatefulWidget {
  FloorLayout({Key? key}) : super(key: key);

  @override
  State<FloorLayout> createState() => _FloorLayoutState();
}

class _FloorLayoutState extends State<FloorLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            ...List.generate(areas.length, (index) {
              return AreaWidget(area: areas[index]);
            }),
            ...List.generate(tables.length, (index) {
              return TableWidget(table: tables[index]);
            }),
          ],
        ),
      ),
    );
  }
}
