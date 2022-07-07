import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../theme/theme_model.dart';
import '../../theme/theme_state_notifier.dart';
import './widgets/floor_layout.dart';
import './widgets/floor_toolbar.dart';

class FloorPlanScreen extends ConsumerStatefulWidget {
  FloorPlanScreen({Key? key}) : super(key: key);

  @override
  _FloorPlanScreenState createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends ConsumerState<FloorPlanScreen> {
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
