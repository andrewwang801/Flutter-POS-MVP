import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/widgets/alert_dialog.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/dimension_constant.dart';
import '../../application/refund_provider.dart';
import '../../application/refund_state.dart';

class RefundWidget extends ConsumerStatefulWidget {
  RefundWidget(
      {required this.salesNo,
      required this.splitNo,
      required this.rcptNo,
      Key? key})
      : super(key: key);

  final int salesNo;
  final int splitNo;
  final String rcptNo;
  @override
  _RefundWidgetState createState() => _RefundWidgetState();
}

class _RefundWidgetState extends ConsumerState<RefundWidget> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(refundProvider.notifier).fetchRefundList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(refundProvider, (previous, RefundState next) {
      if (next.workable == Workable.failure) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message: next.failiure?.errMsg ?? '',
              );
            });
      }
    });

    return Container(
      padding: EdgeInsets.all(Spacing.md),
      width: 300.w,
      height: 250.h,
      child: Column(
        children: [
          Expanded(child: refundTypeList()),
          btnGroup(),
        ],
      ),
    );
  }

  Widget refundTypeList() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(Spacing.sm),
                color: Colors.green,
                child: Text('ID'),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(Spacing.sm),
                color: Colors.red,
                child: Text('Refund Type'),
              ),
            ),
          ],
        ),
        Expanded(
          child: refundTypeListView(),
        ),
      ],
    );
  }

  List<List<String>> refundList = [];
  Widget refundTypeListView() {
    RefundState state = ref.watch(refundProvider);

    if (state.workable == Workable.loading) {
      return const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      refundList = state.refundData?.refundArray ?? [];
      return ListView.builder(
          itemCount: refundList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedID = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                color: index == selectedID
                    ? Colors.green
                    : (index.isEven ? primaryDarkColor : backgroundDarkColor),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        refundList[index][0],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        refundList[index][1],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  int selectedID = -1;
  Widget btnGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
            width: 100.w,
            height: 25.h,
            callback: () {
              ref.read(refundProvider.notifier).doRefund(
                  widget.salesNo, widget.splitNo, widget.rcptNo, selectedID);
            },
            text: 'Refund',
            borderColor: primaryDarkColor,
            fillColor: primaryDarkColor),
        horizontalSpaceMedium,
        CustomButton(
            width: 100.w,
            height: 25.h,
            callback: () {
              Get.back();
            },
            text: 'Close',
            borderColor: primaryDarkColor,
            fillColor: primaryDarkColor),
      ],
    );
  }
}
