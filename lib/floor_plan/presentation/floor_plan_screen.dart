// ignore_for_file: prefer_relative_imports

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raptorpos/floor_plan/presentation/widgets/floor_layout.dart';
import 'package:raptorpos/floor_plan/presentation/widgets/floor_toolbar.dart';

import '../../common/widgets/drawer.dart';
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
    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(AppBar().preferredSize.height),
      //   child: AppBarWidget(false),
      // ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: <Widget>[
                    FloorToolBar(),
                    const FloorLayout(),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
      drawer: SideBarDrawer(),
    );
  }
}
