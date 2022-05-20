import 'package:flutter/material.dart';

import 'package:raptorpos/model/area_model.dart';
import 'package:raptorpos/model/table_model.dart';
import 'package:raptorpos/widgets/floor_plan/area_widget.dart';
import 'package:raptorpos/widgets/floor_plan/table_widget.dart';

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
