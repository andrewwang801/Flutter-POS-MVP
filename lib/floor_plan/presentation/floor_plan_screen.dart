// ignore_for_file: prefer_relative_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/floor_plan/presentation/widgets/floor_layout.dart';
import 'package:raptorpos/floor_plan/presentation/widgets/floor_toolbar.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../provider/table_provider.dart';

class FloorPlanScreen extends ConsumerStatefulWidget {
  const FloorPlanScreen({Key? key}) : super(key: key);

  @override
  _FloorPlanScreenState createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends ConsumerState<FloorPlanScreen> {
  @override
  void initState() {
    ref.read(tableProvider.notifier).fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      appBar: AppBar(
        title: Text('Raptor POS', style: titleTextDarkStyle),
        actions: [
          IconButton(
              icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
              onPressed: () {
                isDark ? isDark = false : isDark = true;
              })
        ],
      ),
      body: Column(
        children: [
          FloorToolBar(),
          FloorLayout(),
        ],
      ),
    );
  }
}
